# Logging Notes

## Scope

This note covers the current structured logging added in `components/chef-automate-collect/commands`.

## Structured Log Format

The current structured log line format is emitted to `stderr` when verbose mode is enabled.

Structured logging can be disabled by setting `CHEF_AC_STRUCTURED_LOGS=false`.
If the variable is unset, or set to any other value, structured logging stays enabled.

Required fields:

- `op`: operation name
- `status`: current outcome (`success` or `error`)
- `elapsed_ms`: elapsed time in milliseconds

Current structured logging path:

- `ConfigLoader.Load()` in `components/chef-automate-collect/commands/automate_config.go`

Example log lines:

```text
op=config_load status=success elapsed_ms=4 config_paths=2
op=config_load status=error elapsed_ms=1 path=/tmp/bad.toml error=decode_toml
```

## How To View Logs

Run from the repository root.

Show computed config and verbose logs:

```sh
cd components/chef-automate-collect
go run . show-config -v
```

Show computed config with structured logs disabled:

```sh
cd components/chef-automate-collect
CHEF_AC_STRUCTURED_LOGS=false go run . show-config -v
```

Test config and verbose logs:

```sh
cd components/chef-automate-collect
go run . test-config -v
```

Because verbose output goes to `stderr`, you can separate it from normal output if needed:

```sh
cd components/chef-automate-collect
go run . show-config -v 2>verbose.log
```

## Guidance

- Reuse the same required fields for future structured logs.
- Add extra fields only when they help identify the failing resource or boundary.
- Do not include secrets in structured fields.
- Prefer logging at boundary operations such as config loading, HTTP calls, and external command execution.
- Use `CHEF_AC_STRUCTURED_LOGS=false` as a low-risk rollback toggle if a new structured log shape causes operator friction.
