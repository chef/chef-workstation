# Configuration Loading Subsystem

## Overview

The `chef-automate-collect` configuration loading subsystem manages loading TOML configuration files from multiple precedence sources, applying environment variable overrides, and validating the final configuration before use.

**Key paths:**
- `components/chef-automate-collect/commands/automate_config.go` — config types, loaders, and merge logic
- `components/chef-automate-collect/commands/environment_variables.go` — env-var constants and lookup
- `components/chef-automate-collect/commands/http_resilience.go` — HTTP resilience wrapper (used by config test)

## Config Precedence (Lowest to Highest)

Configuration is loaded from multiple sources in strict precedence order. Later sources override earlier ones.

1. **System config** — `ConfigLoader.SystemConfigPath` (typically `/etc/chef/automate-collect.toml`)
2. **User config** — `ConfigLoader.UserConfigPath` (typically `~/.chef/automate-collect.toml`)
3. **Repo config** — `ConfigLoader.RepoConfigPath` (`.automate/config.toml` in repo root)
4. **Repo private config** — `ConfigLoader.RepoPrivateConfigPath` (`.automate/config.private.toml` in repo root, secrets only)
5. **Environment variables** — final override (sourced from `ApplyValuesFromEnv()`)

### Load Flow

```
[System Config]
        ↓
[User Config] (overrides system)
        ↓
[Repo Config] (overrides user)
        ↓
[Repo Private Config] (overrides repo, secrets only)
        ↓
[Env Vars] (final override)
        ↓
[Final Config]
```

## Types and Structures

### Config
- `URL` — Chef Automate server endpoint (required)
- `Automate` — AutomateConfig struct containing auth and TLS settings

### PrivateConfig
- Wrapper type used during TOML deserialization to handle sensitive fields
- `Automate` — PrivateAutomateConfig struct with explicit AuthToken field

### AutomateConfig
- `URL` — server endpoint
- `authToken` — private field (not serialized)
- `InsecureTLS` — allows self-signed certificates (development only)

### PrivateAutomateConfig
- `AutomateConfig` — embedded struct (inherits URL, InsecureTLS)
- `AuthToken` — explicitly named auth token for TOML binding
- `InsecureTLS` — explicit binding for TOML override

## Loading Process

### 1. Initialization (`NewConfigLoader()`)

```go
loader := NewConfigLoader()
```

This initializes a `ConfigLoader` and scans for viable config paths:

- Calls `findRepoConfig()` — searches `.automate/config.toml` in repo root
- Calls `findUserConfig()` — searches `~/.chef/automate-collect.toml`
- Calls `findSystemConfig()` — searches `/etc/chef/automate-collect.toml`

### 2. Loading (`ConfigLoader.Load()`)

Iterates through `ViableConfigPaths()` (filtered to non-empty paths only):

- Reads each file as raw bytes
- Unmarshals into `PrivateConfig` struct from TOML
- Merges each config into `LoadedConfig` via `ApplyValuesFrom()`
- Emits structured logs at INFO or ERROR levels

Error handling uses the shared `logConfigLoadError()` helper:
- Emits structured log entry with operation, path, and error reason
- Wraps original error with context-specific message
- Returns immediately on first error (fail-fast)

### 3. Environment Override (`ApplyValuesFromEnv()`)

After all file sources are merged, environment variables are checked and applied:

- `CHEF_AC_URL` — overrides server endpoint
- `CHEF_AC_AUTH_TOKEN` — overrides auth token
- `CHEF_AC_INSECURE_TLS` — enables InsecureTLS mode

### 4. Validation (`AutomateConfig.Test()`)

Before configuration is used, `Test()` validates connectivity:

- Constructs POST request to Chef Automate
- Uses HTTP resilience helper with retry/backoff (3 attempts, 200ms→400ms backoff)
- Per-attempt timeout: 5 seconds
- Returns wrapped error on all retries exhausted
- Emits structured HTTP log with status, elapsed time, and response code

## Resilience Integration

Config validation (`AutomateConfig.Test()`) uses the resilience helper:

- **Retryable statuses:** `500`, `502`, `503`, `504`
- **Retryable errors:** transport-level errors (including timeout-like errors)
- **Max retries:** 3 attempts total
- **Backoff:** exponential starting at 200ms (200ms, then 400ms)
- **Per-attempt timeout:** 5 seconds via request context

See `ai-track-docs/resilience.md` for tuning details.

## Extension Points

### Adding a New Config Source

1. Add discovery logic to a new `find*Config()` method in `ConfigLoader`
2. Call the method in `NewConfigLoader()`
3. Assign the path to the corresponding `ConfigLoader.XyzConfigPath` field
4. Paths are automatically picked up by `ViableConfigPaths()` (filter removes empty paths)
5. Update this document with the new precedence level

**Example:** To add a "project config" source between user and repo config:

```go
func (l *ConfigLoader) findProjectConfig() {
    // Logic to discover .projectname/automate.toml
    l.ProjectConfigPath = filepath.Join(projectRoot, ".projectname", "automate.toml")
}

// In NewConfigLoader(), call it in precedence order:
func NewConfigLoader() *ConfigLoader {
    c := &ConfigLoader{}
    c.findRepoConfig()
    c.findProjectConfig()  // ← NEW
    c.findUserConfig()
    c.findSystemConfig()
    return c
}

// Update load flow and ViableConfigPaths() as needed
```

### Adding a New Environment Variable

1. Add a constant to `environment_variables.go` following the `CHEF_AC_*` pattern
2. Add handling in `AutomateConfig.ApplyValuesFromEnv()`
3. Add a contract test in `environment_variables_test.go`
4. Update this document

**Example:** To add `CHEF_AC_LOG_LEVEL`:

```go
// In environment_variables.go
const LogLevelEnvVar = "CHEF_AC_LOG_LEVEL"

// In automate_config.go
func (c *AutomateConfig) ApplyValuesFromEnv() {
    // ... existing overrides ...
    if logLevel := os.Getenv(LogLevelEnvVar); logLevel != "" {
        c.LogLevel = logLevel
    }
}
```

## Error Handling

Config loading uses structured logging for all error paths:

- **Read errors** — logged as `"read_config"`, wrapped with file path
- **TOML decode errors** — logged as `"decode_toml"`, wrapped with file path
- **HTTP test errors** — logged via resilience helper, includes status code

The shared helper `logConfigLoadError()` ensures consistent error emission:

```go
return logConfigLoadError(start, path, "read_config", err, "failed to read config file %q")
```

This emits a structured log entry and returns a wrapped error in one call.

## Testing

### Existing Tests

- `TestPrivateConfigIsAutomateCollectorConfig` — type marker validation
- `TestPrivateConfigToConfigPreservesAutomateConfig` — conversion correctness
- `TestPrivateAutomateConfigToConfigConvertsProperly` — field override behavior
- `TestViableConfigPathsFiltersEmptyPaths` — empty-path filtering
- `TestLogConfigLoadErrorEmitsStructuredLogAndWrapsError` — error handling + logging
- `TestAutomateConfigTestRetriesTransientServerError` — resilience behavior

### Running Tests

```sh
cd components/chef-automate-collect
go test ./commands -run TestAutomate -count=1 -v
go test ./commands -run TestLogConfig -count=1 -v
go test ./commands -run TestPrivate -count=1 -v
```

## Rollback

If configuration loading behavior changes cause issues:

1. Identify the commit(s) that introduced the change
2. Revert via `git revert <commit-sha>`
3. Validate with `go test ./commands -count=1`
4. If needed, re-introduce the change incrementally or with narrower scope

## See Also

- `ai-track-docs/extending-environment-variables.md` — env-var extension details
- `ai-track-docs/resilience.md` — HTTP resilience tuning and failure behavior
- `ai-track-docs/logging.md` — structured logging guide
