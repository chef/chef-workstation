# Ops Runbook: Resilience Patterns

## Scope

This runbook covers Ex15 command resilience behavior in:

- `components/chef-automate-collect/commands`

## Feature Summary

A timeout/backoff helper wraps external `git` command invocations used by rollout metadata collection.

Applied call paths:

1. `git rev-parse --git-dir`
2. `git rev-list -1 HEAD ...`
3. `git show -s --format=...`
4. `git ls-remote --get-url ...`

## Tuning Parameters

Configured in `metadata_collectors.go` via `gitCommandResilienceOptions`:

- `MaxAttempts` (default `3`)
- `InitialBackoff` (default `150ms`)
- `PerAttemptTimeout` (default `2s`)

Backoff sequence with current defaults:

- attempt 1 -> 2: `150ms`
- attempt 2 -> 3: `300ms`

## Failure Signals

Typical log and error indicators:

- wrapped command failure message including attempt count
- `context deadline exceeded` for timeout-driven retries
- final error return from metadata collection command path

## Escalation Steps

1. Confirm reproducibility with local command:

```sh
cd components/chef-automate-collect
go test ./commands -run 'TestExecuteCommandWithResilience' -count=1 -v
```

2. Validate git command behavior outside the app in the affected repository:

```sh
git -C <repo-path> rev-parse --git-dir
git -C <repo-path> ls-remote --get-url origin
```

3. If failures persist in production workflows:
- collect logs and failing command context
- reduce blast radius by temporarily lowering retries to 1 or increasing timeout to isolate timeout-vs-command errors
- escalate to on-call maintainers with command output and environment details

4. Open incident follow-up if repeated failures exceed operational threshold.

## Rollback

1. Immediate rollback path: revert Ex15 commit in rollout branch.
2. Verify rollback by rerunning:

```sh
cd components/chef-automate-collect
go test ./commands -count=1
go build ./...
```
