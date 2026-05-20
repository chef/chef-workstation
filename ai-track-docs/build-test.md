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
