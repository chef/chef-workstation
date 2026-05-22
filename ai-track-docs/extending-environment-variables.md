# Extending Environment Variables

Target module: `components/chef-automate-collect/commands/environment_variables.go`

## When to update this file

Update this module when `chef-automate-collect` needs a new environment variable for:

- Automate connection settings
- Configuration directory lookup
- Config-source enable/disable behavior
- Reporting or git-source behavior

## How to add a new variable

1. Add the constant to the matching `const` block in `environment_variables.go`.
2. Keep the constant name descriptive and the string value aligned to the existing `CHEF_AC_*` naming pattern.
3. Add or update the consumer in `automate_config.go` or the relevant command file.
4. Update `environment_variables_test.go` so the contract test covers the new constant.

## Validation

Run from the repository root:

```sh
cd components/chef-automate-collect
go test ./commands -run TestEnvironmentVariableConstantsStable -count=1 -v
go build ./...
```

## Notes

- Treat these constants as part of the external configuration surface.
- Changing a constant value is a behavior change, not a refactor.
- Prefer adding to an existing themed block rather than creating ad hoc grouping.

## Ex13 Feature Flag Example

Flag name pattern:

- `CHEF_AC_FF_<BEHAVIOR_NAME>`

Implemented flag:

- `CHEF_AC_FF_HTTP_VERBOSE_DIAGNOSTICS`

Purpose:

- Controls verbose HTTP trace/response diagnostics in `AutomateConfig.Test`.
- Keeps default behavior risk low for higher-impact logging changes by requiring explicit opt-in.

Default state:

- `false` (disabled unless set to `true`).

Toggle mechanism:

- Set `CHEF_AC_FF_HTTP_VERBOSE_DIAGNOSTICS=true` to enable verbose HTTP diagnostics.
- Set `CHEF_AC_FF_HTTP_VERBOSE_DIAGNOSTICS=false` to disable.
- Any invalid value falls back to the default (`false`).

Rollback path:

1. Immediate rollback: set `CHEF_AC_FF_HTTP_VERBOSE_DIAGNOSTICS=false` in the environment.
2. Code rollback: revert the Ex13 feature-flag commit if complete removal is required.