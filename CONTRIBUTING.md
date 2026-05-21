Workstation follows the contributing process detailed in the `chef` project's CONTRIBUTING.md:

Please refer to CONTRIBUTING.md for the `chef` project: https://github.com/chef/chef/blob/main/CONTRIBUTING.md

## Running Tests & Coverage Locally

This repo contains two Go components, each with its own module and test suite.

### `components/chef-automate-collect`

```sh
cd components/chef-automate-collect

# Unit tests with coverage
go test -cover -count=1 ./commands

# Per-function coverage breakdown
go test -coverprofile=coverage.out -count=1 ./commands
go tool cover -func=coverage.out

# Remove artifact after review
rm coverage.out
```

> **Note:** Baseline coverage for `commands/` is intentionally low (~5%). The majority of command functions invoke external HTTP endpoints or process I/O that are not unit-testable without integration infrastructure. The covered surface is the pure-logic layer (env-var constants, config struct parsing, error mapping).

### `components/main-chef-wrapper`

```sh
cd components/main-chef-wrapper

# Unit tests (build-tag gated) with coverage
go test -tags=unit -cover -count=1 ./cmd

# Per-function coverage breakdown
go test -tags=unit -coverprofile=coverage.out -count=1 ./cmd
go tool cover -func=coverage.out

# Remove artifact after review
rm coverage.out
```

> **Baseline:** `cmd/` unit-tagged tests cover **~57%** of statements. Uncovered functions are passthrough command wrappers whose execution path requires a live Chef Infra Server.

### Ruby / Omnibus specs

```sh
# Requires Ruby 2.7 + bundler
bundle install
bundle exec rake omnibus/verification/spec/ --trace
```

CI (`.github/workflows/unit.yml`) runs these specs and enforces a SimpleCov threshold of **79%** via `aki77/simplecov-report-action`.

