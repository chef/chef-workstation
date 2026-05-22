#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
commands_dir="$repo_root/components/chef-automate-collect/commands"

automate_config_file="$commands_dir/automate_config.go"
report_rollout_file="$commands_dir/report_new_rollout.go"

echo "==> Applying Ex14 targeted autofixes in $commands_dir"

# staticcheck S1023: redundant return at end of void functions.
perl -0pi -e 's/\n\tcliIO\.verbose\("found private config file %q", candidatePrivateConfigFilename\)\n\tl\.RepoPrivateConfigPath = candidatePrivateConfigFilename\n\treturn\n\}/\n\tcliIO.verbose("found private config file %q", candidatePrivateConfigFilename)\n\tl.RepoPrivateConfigPath = candidatePrivateConfigFilename\n\}/g' "$automate_config_file"
perl -0pi -e 's/\n\tcliIO\.verbose\("found user config file %q", userConfigFilename\)\n\tl\.UserConfigPath = userConfigFilename\n\treturn\n\}/\n\tcliIO.verbose("found user config file %q", userConfigFilename)\n\tl.UserConfigPath = userConfigFilename\n\}/g' "$automate_config_file"
perl -0pi -e 's/\n\tcliIO\.verbose\("found system config file %q", candidateFilename\)\n\tl\.SystemConfigPath = candidateFilename\n\treturn\n\}/\n\tcliIO.verbose("found system config file %q", candidateFilename)\n\tl.SystemConfigPath = candidateFilename\n\}/g' "$automate_config_file"

# staticcheck ST1005: lowercase user-facing error string.
perl -0pi -e 's/Automate URL %q is invalid; must use \\"https\\" protocol/automate URL %q is invalid; must use \\"https\\" protocol/g' "$automate_config_file"

# go vet copylocks: marshal pointer to avoid copying embedded lock values.
perl -0pi -e 's/json\.Marshal\(reqData\)/json.Marshal\(&reqData\)/g' "$report_rollout_file"

echo "==> Running gofmt on touched files"
gofmt -w "$automate_config_file" "$report_rollout_file"

echo "==> Ex14 autofix complete"