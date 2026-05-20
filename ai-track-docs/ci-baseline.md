# CI Baseline

## Current State

The existing GitHub Actions workflow in `.github/workflows/unit.yml` runs Ruby verification (`bundle exec rake omnibus/verification/spec/ --trace`).

That workflow does not provide a focused, repeatable validation path for the crawl-track changes in `components/chef-automate-collect`.

## Local Fallback Script

Use the local validation script at `scripts/run-crawl-checks.sh`.

Run from the repository root:

```sh
./scripts/run-crawl-checks.sh
```

## What The Script Runs

The script performs the current crawl-track checks for `chef-automate-collect`:

```sh
cd components/chef-automate-collect
go test ./commands -run 'TestStructuredLogLine|TestRedactSecretForLog|TestGitRemoteNameFromEnv|TestEnvironmentVariableConstantsStable' -count=1 -v
go build ./...
```

## Expected Success Signal

- Unit tests pass
- `go build ./...` succeeds
- Script ends with `==> Crawl checks passed`

## Why This Exists

- It gives contributors one copy/paste entry point for the Go slice touched in the crawl exercises.
- It is narrower and faster than broad repo-wide validation.
- It is suitable as a local fallback until CI includes an equivalent focused job for this component.