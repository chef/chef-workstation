# API Contract Hardening Guide

## Overview

This document describes the process for maintaining and extending API contract tests in the Chef Automate Collect subsystem. Contract tests ensure that the public API boundaries are hardened against invalid inputs and edge cases.

## Current API Boundary Contracts

### 1. URL Validation Boundary (`TestURL()` and `CreateRolloutURL()`)

**Location:** `components/chef-automate-collect/commands/automate_config.go`

**Contract:** Both methods validate that `AutomateConfig.URL` is a well-formed HTTP/HTTPS URL with a non-empty host.

**Test Location:** `components/chef-automate-collect/commands/automate_config_test.go`
- `TestTestURLValidatesURL` — validates TestURL() method
- `TestCreateRolloutURLValidatesURL` — validates CreateRolloutURL() method

**Validation Rules:**

| Rule | Behavior | Test Coverage |
|---|---|---|
| Non-empty URL required | Returns error if URL is empty | `empty_url` |
| HTTP/HTTPS scheme required | Returns error for other schemes (ftp, file, etc.) | `invalid_scheme` |
| Non-empty host required | Returns error if host is missing (e.g., `/path/only`) | `relative_path_only`, `no_host` |
| Valid URL syntax | Returns error if URL is malformed | `malformed_url` |
| Valid URLs accepted | HTTPS and HTTP URLs with valid hosts succeed | `valid_https_url`, `valid_http_url` |

**Rationale:**

- **Why validate early:** Catching invalid URLs at the config boundary prevents them from reaching the HTTP layer where failures are harder to diagnose.
- **Why check scheme:** Non-HTTP(S) schemes (e.g., `ftp://`) would fail silently in the HTTP client; early validation provides clear error messages.
- **Why require host:** Path-only URLs (e.g., `/api/endpoint`) are relative and invalid for external API calls.

## Extending API Contracts

### When to Add a Contract Test

Add a contract test when:
- A new public API method is added that accepts external input
- An existing API method has an edge case that could reach invalid state
- A boundary is found where validation can fail silently at a lower layer

### Template: Adding a Contract Test

**Step 1: Identify the boundary**

Example:
```go
func (a *AutomateConfig) NewMethod(input string) error {
    // Processing...
}
```

**Step 2: List edge cases**

```
- empty input
- input with special characters
- input exceeding max length
- input with invalid format
```

**Step 3: Write parameterized test**

```go
func TestNewMethodValidatesInput(t *testing.T) {
    tests := []struct {
        name    string
        input   string
        wantErr bool
        desc    string
    }{
        {name: "valid_input", input: "good", wantErr: false, desc: "valid input should succeed"},
        {name: "empty_input", input: "", wantErr: true, desc: "empty input should fail"},
        // ... more cases
    }

    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := NewMethod(tt.input)
            if (err != nil) != tt.wantErr {
                t.Fatalf("test %q: %s", tt.desc, err)
            }
        })
    }
}
```

**Step 4: Add validation to the method**

```go
func (a *AutomateConfig) NewMethod(input string) error {
    if input == "" {
        return errors.New("input is required")
    }
    // Process...
}
```

**Step 5: Run tests**

```sh
go test ./commands -run TestNewMethod -v
```

## Testing Standards

### Test Naming

- Test name matches the public method: `TestMethodNameValidatesBoundary`
- Sub-tests are descriptive: `empty_input`, `invalid_format`, `too_long`

### Test Structure

- Each test case documents the rule being checked (`desc` field)
- Both success and failure cases are covered
- Edge cases (empty, nil, boundary values) are included

### Running Tests

**All contract tests:**
```sh
cd components/chef-automate-collect
go test ./commands -v
```

**Specific contract test:**
```sh
go test ./commands -run TestTestURLValidatesURL -v
```

**With coverage:**
```sh
go test ./commands -coverprofile=coverage.out
go tool cover -html=coverage.out
```

## Rationale for Current Validations

### Why TestURL() and CreateRolloutURL() Validate

**Problem:** Before hardening, invalid URLs could be silently accepted and only fail when the HTTP request was made, resulting in cryptic errors.

**Solution:** Validate URLs at the config boundary with clear, actionable error messages.

**Examples of errors caught:**

- Empty URL: `"automate URL is required"` (clear)
- Invalid scheme: `"automate URL must use http or https scheme, got 'ftp'"` (helpful)
- No host: `"automate URL must include a host, got '/api/endpoint'"` (unambiguous)

### Failure Impact

Before hardening:
- Error: `"Get http:// : http: no Host in request URL"` (cryptic, in HTTP layer)

After hardening:
- Error: `"automate URL must include a host, got '/api/endpoint'"` (clear, at boundary)

## Future Improvements

**Candidates for contract tests:**
- Auth token validation (non-empty, valid format)
- TLS settings validation (boolean constraints)
- Config file path validation (readable, valid paths)
- HTTP method validation (must be valid HTTP verb)
- Request header validation (valid header format)

**How to add:** Follow the template above and add test cases to `automate_config_test.go`.

## Cross-Reference

- See `ai-track-docs/config-loading.md` for config precedence and loading details
- See `ai-track-docs/resilience.md` for HTTP resilience behavior
- See `components/chef-automate-collect/commands/http_resilience.go` for HTTP layer
