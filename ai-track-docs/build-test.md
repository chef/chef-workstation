# Build & Test Reference

This file documents commands verified during Crawl Exercise 1 and is intended to be copy/paste repeatable from the repository root.

## Prerequisites

```sh
# macOS: install Go if missing
command -v go >/dev/null || brew install go

# confirm toolchain
go version
```

## Build Commands

```sh
# from repo root
cd components/chef-automate-collect
go build ./...
```

## Deterministic Unit Test (Chosen Module)

Target module: `components/chef-automate-collect/commands/environment_variables.go`

```sh
# from repo root
cd components/chef-automate-collect
go test ./commands -run TestEnvironmentVariableConstantsStable -count=1 -v
```

Expected result: `PASS` with exit code `0`.

## Optional Wider Test Sweep

```sh
# from repo root
cd components/chef-automate-collect
go test ./... -count=1
```

## Notes

- The deterministic test validates env var constants and checks for accidental duplicate values.
- This gives a low-risk guardrail for the selected reusable module before changing config behavior elsewhere.

---

## Coverage

*Added: Walk Ex2 – coverage surfacing baseline.*

### Commands: `components/chef-automate-collect`

```sh
cd components/chef-automate-collect
go test -cover -count=1 ./commands
# → ok  ...commands  0.655s  coverage: 4.9% of statements

# Per-function detail
go test -coverprofile=coverage.out -count=1 ./commands && go tool cover -func=coverage.out
rm coverage.out
```

| Package | Coverage | Notes |
|---------|----------|-------|
| `commands/` | **4.9%** | Low by design: most command bodies invoke external HTTP/IO not covered by unit tests. Pure-logic layer (env-var constants, error mapping) is covered. |

### Commands: `components/main-chef-wrapper`

```sh
cd components/main-chef-wrapper
go test -tags=unit -cover -count=1 ./cmd
# → ok  ...cmd  0.528s  coverage: 56.9% of statements

# Per-function detail
go test -tags=unit -coverprofile=coverage.out -count=1 ./cmd && go tool cover -func=coverage.out
rm coverage.out
```

| Package | Coverage | Notes |
|---------|----------|-------|
| `cmd/` (unit tag) | **56.9%** | Covers command wiring, flag registration, and `init()` blocks. Passthrough `RunE` wrappers that delegate to external executables are not reachable under unit tests. |

### Ruby / Omnibus (CI only)

CI enforces **≥ 79%** SimpleCov threshold via `.github/workflows/unit.yml`.
Run locally with:
```sh
bundle exec rake omnibus/verification/spec/ --trace
```

### PR Coverage Snippet Template

Include the following block in every PR description when code changes touch a Go package:

```
## Coverage
- `components/chef-automate-collect/commands`: X.X% (baseline 4.9%)
- `components/main-chef-wrapper/cmd`:          X.X% (baseline 56.9%)
- Command: `go test -tags=unit -cover -count=1 ./cmd`
```

---

## CI Soft Gating (Walk Ex10)

Workflow: `.github/workflows/soft-evidence-summary.yml`

Purpose:

- Publish validation evidence in GitHub Actions Job Summary.
- Stay advisory-only (non-blocking) even if the coverage command fails.

Current soft gate metric:

- `components/main-chef-wrapper/cmd` unit coverage using:
	- `cd components/main-chef-wrapper && go test -tags=unit -cover -count=1 ./cmd`

Where to view in CI:

1. Open the **CI Soft Evidence Summary** workflow run.
2. Open job **Soft coverage summary (advisory)**.
3. Read the **Soft Gate Evidence** section in Job Summary.

Local equivalent command:

```sh
cd components/main-chef-wrapper
go test -tags=unit -cover -count=1 ./cmd
```

Expected behavior:

- Job always passes by design.
- Summary shows `Status=PASS` or `Status=SOFT-FAIL` and includes raw command output for reviewer context.
