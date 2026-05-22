# Backlog EX12: Groomed and Prioritized

Target subsystem: components/chef-automate-collect/commands

Tracker access was not used in this exercise, so this file is the documented backlog artifact for PR attachment/reference.

## Prioritized Backlog Items

### EX12-BL-1 (P1): Remove raw config struct logging in merge path

Priority rationale: highest security-to-effort value, isolated code path, low regression risk.

Good first task: Yes (agent-friendly)

Suggested owner: Agent or new team contributor

Acceptance Criteria

1. Replace raw struct logging in ApplyValuesFrom with safe, field-specific logging.
2. Ensure auth token values are never logged in cleartext from this merge path.
3. Add or adjust a unit test that fails if token material appears in verbose output.

Code links

- [components/chef-automate-collect/commands/automate_config.go](components/chef-automate-collect/commands/automate_config.go#L547)
- [components/chef-automate-collect/commands/automate_config.go](components/chef-automate-collect/commands/automate_config.go#L548)
- [components/chef-automate-collect/commands/automate_config_test.go](components/chef-automate-collect/commands/automate_config_test.go#L245)

### EX12-BL-2 (P1): Stop raw HTTP body/header verbose dumping in test-config path

Priority rationale: reduces accidental secret leakage in verbose logs while preserving troubleshooting value.

Good first task: Yes (agent-friendly)

Suggested owner: Agent or core maintainer

Acceptance Criteria

1. Replace raw response header/body dump with structured/sanitized log fields.
2. Preserve status_code and operation-level diagnostics for failures.
3. Add or adjust tests to ensure response body is not directly emitted to verbose logs by default.

Code links

- [components/chef-automate-collect/commands/automate_config.go](components/chef-automate-collect/commands/automate_config.go#L621)
- [components/chef-automate-collect/commands/automate_config.go](components/chef-automate-collect/commands/automate_config.go#L624)
- [components/chef-automate-collect/commands/automate_config.go](components/chef-automate-collect/commands/automate_config.go#L638)
- [components/chef-automate-collect/commands/automate_config_test.go](components/chef-automate-collect/commands/automate_config_test.go#L35)

### EX12-BL-3 (P2): Add deterministic tests for false-toggles on config disable env vars

Priority rationale: small test-only hardening with clear behavior contract.

Good first task: Yes (team delegation-ready)

Suggested owner: Agent or QA-focused contributor

Acceptance Criteria

1. Add tests covering false vs non-false behavior for CHEF_AC_NO_REPO_CONFIG, CHEF_AC_NO_USER_CONFIG, and CHEF_AC_NO_SYSTEM_CONFIG.
2. Validate that explicit false keeps loading enabled while any other set value disables loading.
3. Keep test scope limited to config path discovery behavior.

Code links

- [components/chef-automate-collect/commands/environment_variables.go](components/chef-automate-collect/commands/environment_variables.go#L42)
- [components/chef-automate-collect/commands/environment_variables.go](components/chef-automate-collect/commands/environment_variables.go#L46)
- [components/chef-automate-collect/commands/environment_variables.go](components/chef-automate-collect/commands/environment_variables.go#L50)
- [components/chef-automate-collect/commands/automate_config.go](components/chef-automate-collect/commands/automate_config.go#L136)
- [components/chef-automate-collect/commands/automate_config.go](components/chef-automate-collect/commands/automate_config.go#L206)
- [components/chef-automate-collect/commands/automate_config.go](components/chef-automate-collect/commands/automate_config.go#L241)

### EX12-BL-4 (P2): Enrich HTTP retry failure context with attempts and final status

Priority rationale: medium effort, high diagnosability for transient failures.

Good first task: No (requires careful error-contract changes)

Suggested owner: Team maintainer

Acceptance Criteria

1. Include attempt count in final error from doHTTPRequestWithResilience when retries are exhausted.
2. Include final retryable status code context in error output while avoiding sensitive body/header data.
3. Update existing resilience tests to assert the new error shape.

Code links

- [components/chef-automate-collect/commands/http_resilience.go](components/chef-automate-collect/commands/http_resilience.go#L20)
- [components/chef-automate-collect/commands/http_resilience.go](components/chef-automate-collect/commands/http_resilience.go#L58)
- [components/chef-automate-collect/commands/http_resilience.go](components/chef-automate-collect/commands/http_resilience.go#L68)
- [components/chef-automate-collect/commands/http_resilience_test.go](components/chef-automate-collect/commands/http_resilience_test.go#L17)

### EX12-BL-5 (P3): Escape structured log values for whitespace and separators

Priority rationale: observability quality improvement for parsers and log tooling.

Good first task: Yes (isolated utility-level change)

Suggested owner: Agent

Acceptance Criteria

1. Ensure structured log values containing spaces or equals signs are safely encoded before emission.
2. Preserve current required fields and field order.
3. Add unit tests covering encoded output for representative edge values.

Code links

- [components/chef-automate-collect/commands/cli_io.go](components/chef-automate-collect/commands/cli_io.go#L51)
- [components/chef-automate-collect/commands/cli_io.go](components/chef-automate-collect/commands/cli_io.go#L62)
- [components/chef-automate-collect/commands/cli_io_test.go](components/chef-automate-collect/commands/cli_io_test.go#L45)

## Prioritization and Delegation Summary

Execution order

1. EX12-BL-1
2. EX12-BL-2
3. EX12-BL-3
4. EX12-BL-4
5. EX12-BL-5

Best first delegation tasks

- EX12-BL-1
- EX12-BL-2
- EX12-BL-3
- EX12-BL-5

## Simulated Patch Plan (Delegation Example)

Chosen item: EX12-BL-1

### 1) Short patch plan

1. Replace raw struct debug line in ApplyValuesFrom with explicit safe fields.
2. Keep URL and InsecureTLS visibility, redact token presence as boolean indicator only.
3. Add a focused verbose-log test that asserts token text never appears.
4. Run focused unit tests in commands package.

### 2) Files to change

- [components/chef-automate-collect/commands/automate_config.go](components/chef-automate-collect/commands/automate_config.go)
- [components/chef-automate-collect/commands/automate_config_test.go](components/chef-automate-collect/commands/automate_config_test.go)

### 3) Simulated diff

File: components/chef-automate-collect/commands/automate_config.go

- cliIO.verbose("applying config %+v to existing %+v", *other, *a)
+ cliIO.verbose("applying config changes url_set=%t token_set=%t insecure_tls_set=%t", other.URL != "", other.authToken != "", other.InsecureTLS)

File: components/chef-automate-collect/commands/automate_config_test.go

+ func TestApplyValuesFromDoesNotLogAuthToken(t *testing.T) {
+     // Arrange two configs with distinct tokens and verbose enabled.
+     // Capture stderr, call ApplyValuesFrom, assert token text is absent.
+ }

### 4) Generate or adjust tests

Add test coverage

- Add TestApplyValuesFromDoesNotLogAuthToken in [components/chef-automate-collect/commands/automate_config_test.go](components/chef-automate-collect/commands/automate_config_test.go)

Focused test command

- go test ./commands -run TestApplyValuesFromDoesNotLogAuthToken -count=1

### 5) Before and after evidence

Before evidence

- [components/chef-automate-collect/commands/automate_config.go](components/chef-automate-collect/commands/automate_config.go#L548) logs full structs with %+v, which can expose secret fields in verbose mode.

After evidence (expected)

- Verbose line contains only booleans for field presence and no raw token value.
- New test fails on token leakage and passes on sanitized logging behavior.

### 6) PR description draft (template)

Title

- Ex12: Backlog grooming artifact for chef-automate-collect commands

Summary

- Adds prioritized Ex12 backlog items for the target subsystem with acceptance criteria, code links, and delegation suitability.
- Includes a simulated patch plan for EX12-BL-1 with files, diff sketch, tests, and evidence expectations.

Changes

- Updated [ai-track-docs/BACKLOG-EX12.md](ai-track-docs/BACKLOG-EX12.md)

Validation

- Doc-only change; no runtime behavior change.

Risks

- Low risk; planning artifact only.

Follow-ups

- Implement EX12-BL-1 as the first delegated patch.