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

## Notes

- This exercise documents existing checks rather than introducing broad new lint gates.
- The current baseline is mixed-language: Ruby lint/spec checks in CI and focused Go checks via local script.
- If future work tightens linting, prefer scoped changes (single component or workflow path) to avoid noisy cross-repo regressions.
