#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
cd "$repo_root/components/main-chef-wrapper"

echo "Running rollout input validation contract tests..."
go test ./cmd -run 'TestValidateRolloutSetupContract' -count=1

echo "Running license flag hardening tests..."
go test -vet=off . -run 'TestLicenseFlagPathUsesChefSubdir|TestEnableLicenseFlagWritesPrivateMarker' -count=1

echo "Verifying hardened patterns are present..."
grep -q 'os.OpenFile(licenseFlagPath(home), os.O_WRONLY|os.O_CREATE|os.O_TRUNC, 0o600)' main.go
grep -q 'validateHTTPURL' cmd/push.go

echo "Security hygiene checks passed."
