# Resilience Notes

## Scope

This note documents Ex15 resilience improvements in `chef-automate-collect`.

Target folder:

- `components/chef-automate-collect/commands`

## Current Behavior Before Ex15

The following external `git` command call paths in `ReadGitMetadata()` had no timeout/backoff handling and failed immediately on transient command errors:

1. `git rev-list -1 HEAD ...` commit lookup
2. `git show -s --format=...` metadata extraction
3. `git ls-remote --get-url ...` remote URL resolution

Under failure, each path returned an error (or unknown SCM fallback for repo detection) without retrying transient conditions.

## Improvement Implemented

Paths:

- `components/chef-automate-collect/commands/command_resilience.go`
- `components/chef-automate-collect/commands/metadata_collectors.go`
- `components/chef-automate-collect/commands/command_resilience_test.go`
- `ai-track-docs/ops-runbook.md`

Change:

- Added a shared command resilience helper with:
	- bounded retry attempts
	- exponential backoff between attempts
	- per-attempt timeout via context
- Applied helper to multiple external `git` call paths in `ReadGitMetadata()`:
	- repo detection: `git rev-parse --git-dir`
	- commit lookup: `git rev-list -1 HEAD ...`
	- commit metadata extraction: `git show -s --format=...`
	- remote URL lookup: `git ls-remote --get-url ...`

Why this helps:

- Transient external command failures now get automatic retries.
- External command attempts are bounded by per-attempt timeout.
- Retry behavior is now consistent across multiple git metadata collection paths.

## Tuning Parameters

Current defaults (in code):

- `MaxAttempts`: `3`
- `InitialBackoff`: `150ms`
- `PerAttemptTimeout`: `2s`

The effective max retry wait time is exponential backoff:

- attempt 1 -> attempt 2: `150ms`
- attempt 2 -> attempt 3: `300ms`

Total added wait from backoff is up to `450ms` (excluding per-attempt execution time).

## Failure Behavior

- External command failures are retried up to max attempts.
- Timeout-like command failures are retried up to max attempts.
- On exhaustion, the final wrapped error is returned to existing handling logic.

## Tests Added

- `TestExecuteCommandWithResilienceRetriesOnErrorThenSucceeds`
- `TestExecuteCommandWithResilienceReturnsErrorAfterExhaustion`
- `TestExecuteCommandWithResilienceHandlesTimeouts`

Locations:

- `components/chef-automate-collect/commands/command_resilience_test.go`

## Rollback Guidance

If this causes unexpected behavior in production:

1. Revert the Ex15 commit on the branch/PR.
2. Confirm previous behavior by running `go test ./commands -count=1` in `components/chef-automate-collect`.
3. If needed, re-introduce one call path at a time (start with `git ls-remote` lookup) and iterate.

## Validation Command

Run from repository root:

```sh
cd components/chef-automate-collect
go test ./commands -run 'TestExecuteCommandWithResilience' -count=1 -v
go test ./commands -count=1
go build ./...
```
