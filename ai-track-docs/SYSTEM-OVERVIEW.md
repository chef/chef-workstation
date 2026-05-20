# Chef Workstation – System Overview

## What This Repo Builds

Chef Workstation packages the local developer/operator toolchain for Chef usage across macOS, Linux, and Windows. The repository combines:

- Go CLIs for command execution and telemetry-related workflows.
- Ruby/gems payload and scripts included in the workstation runtime.
- Packaging/release infrastructure (Omnibus + Habitat).

## Entry Points

| Entry point | Location | Role |
|-------------|----------|------|
| `chef` CLI wrapper | `components/main-chef-wrapper/main.go` | Initializes environment and runs Cobra command tree (`cmd` package). |
| `chef-automate-collect` CLI | `components/chef-automate-collect/chef_automate_collect.go` | Runs telemetry/config command tree for Automate collection workflows. |
| Package build entry | `omnibus/` + `habitat/plan.sh` | Produces distributable workstation artifacts. |

## High-Level Component Map

| Component | Language | Notes |
|-----------|----------|-------|
| `components/main-chef-wrapper` | Go | Primary command router and pass-through wrapper around workstation tools via Cobra commands in `cmd/`. |
| `components/chef-automate-collect` | Go | Secondary CLI with focused config/describe/report commands for Automate workflows. |
| `components/gems` | Ruby | Bundled Ruby dependencies used by workstation tooling. |
| `omnibus` | Ruby/Omnibus | Build/packaging definitions for releases. |
| `habitat` | Shell/Habitat | Habitat plan used in packaging pipeline. |

## Test Approach In This Repo

- Go command packages rely heavily on `*_test.go` unit tests colocated with command files (notably in `components/main-chef-wrapper/cmd/`).
- Integration-style tests exist under component-level `integration/` directories (for example `components/chef-automate-collect/integration/`).
- `components/main-chef-wrapper/main.go` documents tagged invocations for test separation:
	- Unit: `go test -tags=unit ./cmd -v -count=1 --cover`
	- Integration: `go test -tags=integration ./integration -v -count=1 --cover`

## Chosen Low-Risk Reusable Module

### Module

`components/chef-automate-collect/commands/environment_variables.go`

### Why This Is Low Risk

- It defines constants only (no I/O, no side effects, no process execution).
- Blast radius is limited to config/env binding behavior in `chef-automate-collect`.
- It is already consumed by config-loading code (`automate_config.go`), so improving/reusing it has immediate value without touching core CLI execution paths.
- Changes here are straightforward to verify by targeted command/config tests and do not require submodule or vendor changes.

### Reuse Plan

Use this file as the canonical env-var contract for Crawl/Exercise work (prompting, validation updates, and config docs) to avoid duplicated string literals and reduce typo risk.
