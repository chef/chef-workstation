# Security and Secrets Hygiene

## Scope

This note covers local secret-handling hygiene for the current crawl-track slice, especially `chef-automate-collect` configuration and developer-created secret files.

## Current Improvement

The `chef-automate-collect` config loader no longer emits the raw `CHEF_AC_AUTOMATE_TOKEN` value in verbose logs.

- Before: verbose logging printed the token value directly.
- After: verbose logging prints `[REDACTED]` for non-empty token values.

This reduces the chance of leaking credentials into terminal logs, CI logs, or copied troubleshooting output.

## Ignore Rules Added

The repository `.gitignore` now ignores common local secret artifacts:

- `.env`
- `.env.*` except `.env.example`
- `*.pem`
- `*.key`
- `*.p12`
- `*.pfx`
- `.netrc`
- `secrets.yml`
- `secrets.local.yml`

These are intended for developer-local credentials and should not be committed.

## Practical Rules

- Do not log raw tokens, passwords, or private keys, even in verbose/debug output.
- Prefer environment variables or ignored local files for local credentials.
- Treat `.automate_collector_private.toml` as secret-bearing configuration.
- If a value is sensitive, log presence or redacted state, not the content.
- When adding new secret inputs, update both ignore rules and nearby docs if local files are involved.

## Validation

Run from the repository root:

```sh
cd components/chef-automate-collect
go test ./commands -run 'TestRedactSecretForLog|TestGitRemoteNameFromEnv|TestEnvironmentVariableConstantsStable' -count=1 -v
go build ./...
```

## Secret Scanning Baseline (Walk Ex8)

Lightweight repository scanning is now part of CI via:

- `.github/workflows/secret-scan.yml`

This workflow runs Gitleaks against the checked-out workspace (`detect --source . --no-git`) and fails the job when new findings are detected.

### Local Command

```sh
gitleaks detect --source . --no-git --config .gitleaks.toml
```

### Findings Remediated

- Replaced test-only key-like placeholder values in `components/main-chef-wrapper/main_test.go` with `test-token-not-secret`.

### Justified Ignore

`.gitleaks.toml` includes a narrow allowlist entry for:

- `components/main-chef-wrapper/dist/licensingConfig.json`

Reason: this file contains a known non-production licensing acceptance fixture value required by workstation licensing configuration, not a developer credential.

If this fixture changes, update the allowlist entry and rerun the local command above before opening a PR.

## Main Chef Wrapper Security Hardening (Run Ex8)

Scope: `components/main-chef-wrapper`

### Fixes Applied

1. Hardened rollout environment validation in `cmd/push.go`:
- `CHEF_AC_SERVER_URL` and `CHEF_AC_AUTOMATE_URL` must be valid absolute `http/https` URLs.
- `CHEF_AC_SERVER_USER` and `CHEF_AC_AUTOMATE_TOKEN` are trimmed and rejected if they contain newline characters.

2. Hardened license feature flag file handling in `main.go`:
- License marker path handling now uses a shared helper (`licenseFlagPath`).
- Marker file creation now uses `os.OpenFile(..., 0o600)` and `.chef` directory creation uses `0o700`.
- Write errors are checked instead of ignored.

### Why This Matters

- URL validation reduces risk of malformed/unexpected endpoint values being passed to rollout reporting.
- Control-character rejection reduces risk of newline-based log/argument confusion.
- Private file permissions for license marker reduce local secret/config exposure on multi-user systems.

### Repeatable Scripted Verification

Run from repo root:

```sh
bash components/main-chef-wrapper/security_hygiene_check.sh
```

This script reruns contract tests for rollout validation, reruns license file permission tests, and verifies hardened code patterns are still present.