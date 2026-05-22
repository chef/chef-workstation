Workstation follows the contributing process detailed in the `chef` project's CONTRIBUTING.md:

Please refer to CONTRIBUTING.md for the `chef` project: https://github.com/chef/chef/blob/main/CONTRIBUTING.md

## Walk Track Workflow (Plan-First, Evidence-Backed)

Use this section for AI Track "Walk" exercises and small incremental refactors.

### Branching Strategy (stacked PRs)

Create each new exercise branch from the previous exercise branch so each PR shows a single logical delta.

- Ex1: `learn/walk/neha-p6-ex1` based on the final crawl branch
- Ex2: `learn/walk/neha-p6-ex2` based on Ex1
- Ex3: `learn/walk/neha-p6-ex3` based on Ex2
- ExN: based on Ex(N-1)

PR base targets should follow the same chain:

- Ex1 PR base: previous crawl branch (or `main` if requested)
- ExN PR base: `learn/walk/neha-p6-ex(N-1)`

### Plan-First Rule

Before generating diffs, write a short implementation plan that includes:

- files to change (2-4 files for tiny refactors)
- reason for each change
- expected behavior impact (usually none for refactors)
- validation commands you will run

### PR Expectations

Keep PRs small, reversible, and evidence-backed.

- Include plan summary in PR body
- Include exact commands executed and short output summary
- Include coverage percentage when the exercise requires it
- Include risk and rollback (revert commit SHA)
- Keep secrets out of prompts, logs, and commits
- Exclude `vendor/` and submodule paths from edits
- Use signed commits (`git commit -s`)

Recommended title format:

- `GHCP -- Walk: Ex<no> <short name>`

### Copilot Usage For Walk Exercises

When collaborating with Copilot, request this sequence explicitly:

1. Propose a plan (files, reason, impact)
2. Generate diffs file-by-file according to the plan
3. Run tests/lint and summarize outputs
4. Draft PR description with evidence and rollback details

If a full suite fails due to known environment gaps, include the failure output and identify whether the failure is pre-existing or unrelated to the current diff.

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

