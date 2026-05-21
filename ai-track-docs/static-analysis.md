# Static Analysis and Lint Baseline

## Scope

This note documents the checks currently available in this repository and how to run them locally.

## Current Checks

### 1) Ruby style lint (Chefstyle/RuboCop)

Defined in `Rakefile` as task `style`.

- `rake style`
- Uses `chefstyle` and `rubocop/rake_task` with explicit options.

References:

- `Rakefile`

### 2) Ruby verification in CI

Current GitHub Actions workflow runs Ruby verification specs:

- `bundle exec rake omnibus/verification/spec/ --trace`

References:

- `.github/workflows/unit.yml`

### 3) Local Go slice validation (crawl track)

The local fallback script checks the focused `chef-automate-collect` path:

- targeted Go tests for current crawl-track guardrails
- `go build ./...`

Reference:

- `scripts/run-crawl-checks.sh`

### 4) Spell-check configuration available

`cspell.json` is present with project dictionaries and ignore patterns.

Reference:

- `cspell.json`

### 5) Docs lint configuration available

`.vale.ini` is present and configured for markdown docs style checks.

Reference:

- `.vale.ini`

### 6) Path-scoped strict static analysis (Walk Ex14)

GitHub Actions workflow enforces `staticcheck` on one focused path:

- target: `components/chef-automate-collect/commands`
- workflow: `.github/workflows/staticcheck-commands.yml`

This gate is intentionally scoped so unrelated code paths are not blocked.

Suppression used:

- File: `components/chef-automate-collect/commands/automate_config.go`
- Check: `ST1005`
- Rationale: error text is intentionally capitalized because it is user-facing CLI output and should remain consistent with existing command messaging.

## How To Run Locally

Run from repository root.

### Ruby style checks

```sh
bundle install
bundle exec rake style
```

### Ruby verification checks (same path as CI unit workflow)

```sh
bundle install
bundle exec rake omnibus/verification/spec/ --trace
```

### Focused Go crawl-track checks

```sh
./scripts/run-crawl-checks.sh
```

### Optional spell-check run (if cspell is installed)

```sh
cspell "**/*.{md,rb,go}"
```

### Strict staticcheck for commands path

```sh
cd components/chef-automate-collect
"$(go env GOPATH)/bin/staticcheck" ./commands
```

## Notes

- This exercise documents existing checks rather than introducing broad new lint gates.
- The current baseline is mixed-language: Ruby lint/spec checks in CI and focused Go checks via local script.
- If future work tightens linting, prefer scoped changes (single component or workflow path) to avoid noisy cross-repo regressions.
- Walk Ex14 applies that principle by gating only the commands path with stricter static analysis.
