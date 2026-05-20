# Build & Test Reference

> Placeholder – update as you verify commands during the AI track exercises.

## Prerequisites

<!-- Go version, Ruby version, Habitat, Docker, etc. -->

## Building

```sh
# Go components (example)
cd components/main-chef-wrapper && go build ./...
cd components/chef-automate-collect && go build ./...
```

## Running Tests

```sh
# Go unit tests
go test ./...

# Ruby / Rake
bundle exec rake
```

## Linting / Static Analysis

```sh
# Go
go vet ./...

# Spell check
cspell "**/*.{go,rb,md}"
```

## CI / Release

- Habitat plan: `habitat/plan.sh`
- Omnibus packaging: `omnibus/`
- See [RELEASE_PROCESS.md](../RELEASE_PROCESS.md) for the release workflow.
