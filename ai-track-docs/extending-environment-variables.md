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