# Dependency Notes

## Scope

This note captures dependency hygiene guidance for the current Crawl-track slice, with emphasis on `components/chef-automate-collect` and the top-level Ruby packaging/tooling manifests.

## Critical Dependencies

### Go: `components/chef-automate-collect/go.mod`

Current notable dependencies:

- `github.com/spf13/cobra v1.0.1-0.20200713175500-884edc58ad08`
  - CLI command framework. Behavior-sensitive because command wiring and help output depend on it.
- `github.com/sirupsen/logrus v1.6.0`
  - Logging surface used by command execution and error reporting.
- `github.com/BurntSushi/toml v0.3.1`
  - Config parsing dependency.
- `github.com/chef/automate v0.0.0-20200818181041-394b5621f411`
  - Internal API dependency for request/metadata types.
- `github.com/chef/chef-workstation/components/main-chef-wrapper v0.0.0-20210410003939-c8367d57bf63`
  - Internal cross-component dependency using a pseudo-version.
- `github.com/stretchr/testify v1.6.1`
  - Test helper dependency.

### Ruby: root `Gemfile`

Development-only tooling currently floats:

- `chefstyle`
- `rake`
- `chef-cli`
- `rspec`
- `simplecov`

This is acceptable for local development, but it means tool behavior can drift unless lockfiles or CI constraints absorb that variability.

### Ruby: `components/gems/Gemfile`

This file already shows the repo's practical dependency policy:

- exact pins when breakage is known (`rake`, `stringio`, `pry`)
- upper bounds for runtime/toolchain compatibility (`chef`, `inspec-bin`, `r18n-desktop`, `activesupport`, `nokogiri`)
- floor constraints for security or minimum supported behavior (`net-imap`, `chef-telemetry`, `mixlib-install`)

## Minimal Pinning / Constraint Recommendations

These are intentionally small-scope recommendations. They do not require a major upgrade.

1. Keep using explicit upper bounds where Ruby version compatibility is the real constraint.
   - The current `components/gems/Gemfile` already does this correctly for gems that require Ruby `>= 3.2`.

2. Prefer replacing long-lived pseudo-versions for internal Go dependencies with tagged versions when available.
   - `github.com/chef/chef-workstation/components/main-chef-wrapper` currently uses a pseudo-version.
   - Minimal constraint recommendation: do not upgrade behavior now, but track this as technical debt and tag internal component releases when the workflow supports it.

3. Record a supported Go toolchain floor near the component.
   - `components/chef-automate-collect/go.mod` still declares `go 1.14`, while local validation for this track used a much newer toolchain.
   - Minimal constraint recommendation: document the minimum supported Go version used in CI before changing the `go` directive.

4. Keep security-driven lower bounds documented inline.
   - The Ruby manifests already do this well for CVE-driven pins.
   - Apply the same pattern to Go dependencies if a future fix requires a minimum patch level.

5. Avoid broad dependency refreshes in crawl-track PRs.
   - For this stage, prefer one of: exact pin, upper bound, or floor change for a single documented reason.

## Practical Policy

Use these rules when touching dependencies in this repo:

- Pin exactly when a known regression or packaging conflict exists.
- Use upper bounds when language/runtime compatibility is the controlling constraint.
- Use minimum versions when carrying a security fix or required feature floor.
- Avoid unrelated upgrades in behavior-focused PRs.
- Document the reason next to the constraint, not just in the PR.

## Follow-Up Candidates

Low-risk future cleanup candidates:

- Audit whether `components/chef-automate-collect/go.mod` can move from `go 1.14` to the minimum version actually used in CI.
- Review whether the internal `main-chef-wrapper` pseudo-version can be replaced by a tagged internal release.
- Decide whether the root development `Gemfile` should rely on a lockfile or more explicit version guidance for repeatable local setup.
