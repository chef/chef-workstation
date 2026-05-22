# Backlog EX12

This backlog is formatted to be easy to copy into Azure Boards or a similar tracker.

## BL-001: Align Go toolchain baseline for chef-automate-collect

**Observation**

`chef-automate-collect` still declares `go 1.14`, while recent local validation for this repo used a much newer Go toolchain.

**Acceptance Criteria**

1. Confirm the minimum Go version used in CI and by supported contributor workflows.
2. Either update `components/chef-automate-collect/go.mod` to the supported floor or document why `go 1.14` must remain.
3. Record the decision in a contributor-facing doc so local setup and CI expectations match.

**Code Links**

- [components/chef-automate-collect/go.mod#L3](components/chef-automate-collect/go.mod#L3)

## BL-002: Add focused Go validation to CI for crawl-track checks

**Observation**

The current GitHub Actions workflow runs Ruby verification only. The focused Go validation path for `chef-automate-collect` exists as a local script, but not as a CI job.

**Acceptance Criteria**

1. Add a CI job that runs the same focused checks as the local fallback script.
2. Keep the job scoped to `chef-automate-collect` rather than widening to repo-wide Go validation.
3. Document the CI job name and when contributors should use local fallback versus CI.

**Code Links**

- [.github/workflows/unit.yml#L16](.github/workflows/unit.yml#L16)
- [.github/workflows/unit.yml#L26](.github/workflows/unit.yml#L26)
- [scripts/run-crawl-checks.sh#L17](scripts/run-crawl-checks.sh#L17)

## BL-003: Remove raw config struct logging from AutomateConfig merge path

**Observation**

`ApplyValuesFrom` currently logs whole config structs with `%+v`, which is risky because the struct contains secret-bearing fields such as `authToken`.

**Acceptance Criteria**

1. Replace raw struct dumping with safe, field-specific logging.
2. Ensure no secret-bearing field values are written to verbose logs.
3. Add a test proving secret values are not exposed through the replacement logging path.

**Code Links**

- [components/chef-automate-collect/commands/automate_config.go#L515](components/chef-automate-collect/commands/automate_config.go#L515)
- [components/chef-automate-collect/commands/automate_config.go#L520](components/chef-automate-collect/commands/automate_config.go#L520)

## BL-004: Extend structured logging to HTTP config-test requests

**Observation**

Structured logs now exist for `config_load`, but the HTTP request path still emits ad hoc trace lines and raw response diagnostics.

**Acceptance Criteria**

1. Add structured logs for the HTTP config-test boundary using consistent fields such as `op`, `status`, and `elapsed_ms`.
2. Include a small set of safe extra fields such as host or response code.
3. Avoid logging secret headers or raw sensitive body content by default.

**Code Links**

- [components/chef-automate-collect/commands/automate_config.go#L111](components/chef-automate-collect/commands/automate_config.go#L111)
- [components/chef-automate-collect/commands/automate_config.go#L543](components/chef-automate-collect/commands/automate_config.go#L543)
- [components/chef-automate-collect/commands/automate_config.go#L557](components/chef-automate-collect/commands/automate_config.go#L557)

## BL-005: Replace or govern internal Go pseudo-versions

**Observation**

The component depends on internal modules via pseudo-versions. That makes the dependency baseline harder to reason about and less predictable for release/backport work.

**Acceptance Criteria**

1. Decide whether internal components should publish tags for dependency consumption.
2. Replace long-lived pseudo-versions with tagged versions where the release process supports it.
3. If tags are not yet feasible, document the policy for when pseudo-versions are allowed.

**Code Links**

- [components/chef-automate-collect/go.mod#L7](components/chef-automate-collect/go.mod#L7)
- [components/chef-automate-collect/go.mod#L8](components/chef-automate-collect/go.mod#L8)