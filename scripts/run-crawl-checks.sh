#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
component_dir="$repo_root/components/chef-automate-collect"

if ! command -v go >/dev/null 2>&1; then
	echo "go is required but was not found in PATH" >&2
	exit 1
fi

echo "==> Running focused crawl checks for chef-automate-collect"

cd "$component_dir"

echo "==> go test ./commands"
go test ./commands -run 'TestStructuredLogLine|TestRedactSecretForLog|TestGitRemoteNameFromEnv|TestEnvironmentVariableConstantsStable' -count=1 -v

echo "==> go build ./..."
go build ./...

echo "==> Crawl checks passed"