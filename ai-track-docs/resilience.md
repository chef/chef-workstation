# Resilience Notes

## Scope

This note documents a small reliability improvement in `chef-automate-collect` config testing.

## Improvement Implemented

Path:

- `components/chef-automate-collect/commands/automate_config.go`

Change:

- `AutomateConfig.Test()` now maps non-200 HTTP responses to returned errors.
- It no longer exits the process directly inside the helper path.

Why this helps:

- Callers can handle errors consistently.
- Failure behavior is easier to test and reason about.
- The command still fails appropriately via normal error return handling.

## Failure Behavior

For non-200 responses, the mapped error now includes:

- target URL
- status code
- optional response body snippet (trimmed and truncated)

This gives enough context for troubleshooting without forcing process termination in lower-level code.

## Tests Added

- `TestMapTestConfigHTTPErrorWithoutBody`
- `TestMapTestConfigHTTPErrorWithBodyTruncatesLongBody`

Both are in:

- `components/chef-automate-collect/commands/automate_config_test.go`

## Validation Command

Run from repository root:

```sh
cd components/chef-automate-collect
go test ./commands -run 'TestMapTestConfigHTTPError|TestRedactSecretForLog|TestStructuredLoggingEnabled|TestStructuredLogLine|TestGitRemoteNameFromEnv|TestEnvironmentVariableConstantsStable' -count=1 -v
go build ./...
```
