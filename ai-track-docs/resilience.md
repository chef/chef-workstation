# Resilience Notes

## Scope

This note documents Ex15 resilience improvements in `chef-automate-collect`.

## Improvement Implemented

Paths:

- `components/chef-automate-collect/commands/http_resilience.go`
- `components/chef-automate-collect/commands/automate_config.go`
- `components/chef-automate-collect/commands/report_new_rollout.go`

Change:

- Added a shared HTTP resilience helper with:
	- bounded retry attempts
	- exponential backoff between attempts
	- per-attempt timeout via request context
- Integrated helper at two external call sites:
	- `AutomateConfig.Test()`
	- `runReportNewRolloutCommand()` API call path

Why this helps:

- Transient server/network failures now get automatic retries.
- Requests no longer risk hanging indefinitely per attempt.
- Retry behavior is consistent across both call sites.

## Tuning Parameters

Current defaults (in code):

- `MaxAttempts`: `3`
- `InitialBackoff`: `200ms`
- `PerAttemptTimeout`: `5s`
- `RetryStatusCodes`: `500`, `502`, `503`, `504`

The effective max retry wait time is exponential backoff:

- attempt 1 -> attempt 2: `200ms`
- attempt 2 -> attempt 3: `400ms`

Total added wait from backoff is up to `600ms` (excluding request execution time).

## Failure Behavior

- Retryable HTTP statuses (`500/502/503/504`) are retried up to max attempts.
- Transport-level errors (including timeout-like errors) are retried up to max attempts.
- Non-retryable statuses are returned immediately to existing status handling logic.

## Tests Added

- `TestDoHTTPRequestWithResilienceRetriesRetryableStatus`
- `TestDoHTTPRequestWithResilienceRetriesTimeoutLikeErrors`
- `TestDoHTTPRequestWithResilienceSetsPerAttemptTimeout`
- `TestAutomateConfigTestRetriesTransientServerError`

Locations:

- `components/chef-automate-collect/commands/http_resilience_test.go`
- `components/chef-automate-collect/commands/automate_config_test.go`

## Rollback Guidance

If this causes unexpected behavior in production:

1. Revert the Ex15 commit on the branch/PR.
2. Confirm previous behavior by running `go test ./commands -count=1` in `components/chef-automate-collect`.
3. If needed, re-introduce only one call-site integration first (start with `AutomateConfig.Test()`) and iterate.

## Validation Command

Run from repository root:

```sh
cd components/chef-automate-collect
go test ./commands -count=1
go build ./...
```
