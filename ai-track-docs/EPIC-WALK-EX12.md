# Epic: Walk Track Follow-up Hardening (Ex12)

## Epic Goal

Convert findings from Walk exercises into small, reviewable follow-up PRs that improve reliability, developer ergonomics, and signal quality without broad refactors.

## Scope

- 5 backlog items, each intended to fit in one PR.
- Focus areas: test reliability, CI signal quality, security scan governance, and observability consistency.
- Code paths are linked for each issue.

## Out of Scope

- Large module re-architecture.
- Multi-component dependency overhauls.
- Vendor or submodule changes.

---

## Issue EX12-1: Stabilize main-chef-wrapper full test invocation

### Why

Running full module tests currently fails due format-string diagnostics in the main package, which weakens confidence when contributors attempt broader local validation.

### Acceptance Criteria

1. `go test ./... -count=1` succeeds in `components/main-chef-wrapper` on supported local toolchains.
2. Changes are limited to fixing diagnostics without changing CLI behavior.
3. Add/update tests if needed to preserve behavior around startup helpers.

### Code Paths

- `components/main-chef-wrapper/main.go`
- `components/main-chef-wrapper/main_test.go`

### Dependencies

- None.

---

## Issue EX12-2: Add advisory benchmark reporting for structured log hot path

### Why

We now have a measured optimization in structured log formatting; a lightweight advisory benchmark signal in CI would surface regressions early without blocking merges.

### Acceptance Criteria

1. Add a non-blocking workflow/job that runs `BenchmarkStructuredLogLine`.
2. Publish benchmark output in Job Summary (and/or logs) with clear advisory labeling.
3. Keep workflow scope limited to relevant paths in `components/chef-automate-collect/commands`.

### Code Paths

- `components/chef-automate-collect/commands/cli_io.go`
- `components/chef-automate-collect/commands/cli_io_test.go`
- `.github/workflows/`

### Dependencies

- None.

---

## Issue EX12-3: Replace raw config struct verbose logging in ApplyValuesFrom

### Why

`ApplyValuesFrom` still logs raw struct values, which can include secret-bearing fields if this path evolves.

### Acceptance Criteria

1. Remove raw `%+v` struct logging in `ApplyValuesFrom`.
2. Replace with field-specific safe logging that redacts or omits sensitive values.
3. Add a test proving sensitive token content is never emitted via this path.

### Code Paths

- `components/chef-automate-collect/commands/automate_config.go`
- `components/chef-automate-collect/commands/automate_config_test.go`

### Dependencies

- None.

---

## Issue EX12-4: Harden secret-scan allowlist governance

### Why

The current gitleaks allowlist intentionally permits one known fixture value; governance should ensure future allowlist edits remain narrowly scoped and justified.

### Acceptance Criteria

1. Document an allowlist governance checklist (single-file scope, exact value, reason, owner).
2. Add CI validation that fails if `.gitleaks.toml` introduces broad patterns (for example, wildcard paths or overly generic regex).
3. Update security notes with maintenance instructions for fixture rotation.

### Code Paths

- `.gitleaks.toml`
- `.github/workflows/secret-scan.yml`
- `ai-track-docs/security-secrets.md`

### Dependencies

- None.

---

## Issue EX12-5: Enforce stacked-PR base correctness with helper tooling

### Why

The Walk flow depends on correct PR base selection (`ExN` -> `ExN-1`). Lightweight automation would reduce accidental base mistakes and noisy review diffs.

### Acceptance Criteria

1. Add a helper script or documented command flow that checks expected branch ancestry and PR base target.
2. Provide clear output for pass/fail and remediation command.
3. Document usage in contributor docs for Walk exercises.

### Code Paths

- `CONTRIBUTING.md`
- `ai-track-docs/onboarding-walk.md`
- `scripts/` (new helper if implemented)

### Dependencies

- Depends on agreement of canonical stacked naming convention already described in `CONTRIBUTING.md`.

---

## Dependency Map

- `EX12-1` independent.
- `EX12-2` independent.
- `EX12-3` independent.
- `EX12-4` independent.
- `EX12-5` depends on current branch naming convention in `CONTRIBUTING.md`.

## Suggested Delivery Order

1. EX12-1
2. EX12-3
3. EX12-4
4. EX12-2
5. EX12-5
