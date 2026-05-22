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

---

## Ex14 Type Safety / Static Analysis (Scoped)

Target folder:

- `components/chef-automate-collect/commands`

Strictness update:

- Added scoped `staticcheck` configuration in `components/chef-automate-collect/staticcheck.conf` with strict checks and scoped suppressions: `checks = ["all", "-ST1000", "-ST1003"]`.
- Added stricter local analyzer pass using `go test ./commands -vet=all -run '^$'`.

Baseline findings count (before fixes):

1. `staticcheck ./commands/...` -> 4 findings
2. `go test ./commands -vet=all -run '^$'` -> 1 finding
3. Total high-signal findings addressed in Ex14 -> 5

Improved findings count (after fixes and scoped suppressions):

1. `staticcheck ./commands/...` -> 0 findings
2. `go test ./commands -vet=all -run '^$'` -> 0 findings
3. Total remaining high-signal findings in scoped checks -> 0

Resolved findings summary:

1. `S1023` redundant return in `findRepoConfig`
2. `S1023` redundant return in `findUserConfig`
3. `S1023` redundant return in `findSystemConfig`
4. `ST1005` capitalized error string in `newAutomateConfig`
5. `go vet` copylocks warning in `report_new_rollout` JSON marshal path

Suppressions:

1. `ST1000` suppressed in scoped config.
2. `ST1003` suppressed in scoped config.

Suppression justification:

- `ST1000` is low-signal for this exercise and would require broad package-doc touch points outside the targeted high-signal fixes.
- `ST1003` currently flags existing upstream/protobuf-derived naming shapes in metadata constants; renaming would have wider API surface impact than desired for this scoped exercise.
- High-signal correctness and type-safety findings remained enforced and were fixed.

Autofix script:

- `scripts/autofix-static-analysis-ex14.sh`
- Applies deterministic mechanical fixes for the 5 Ex14 findings and runs `gofmt` on touched files.

Post-fix verification commands:

```sh
cd components/chef-automate-collect
~/go/bin/staticcheck ./commands/...
go test ./commands -vet=all -run '^$'
```
