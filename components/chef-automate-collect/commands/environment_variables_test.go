package commands

import "testing"

func TestEnvironmentVariableConstantsStable(t *testing.T) {
	tests := map[string]string{
		"AutomateURLEnvVar":             AutomateURLEnvVar,
		"AutomateTokenEnvVar":           AutomateTokenEnvVar,
		"AutomateInsecureTLSEnvVar":     AutomateInsecureTLSEnvVar,
		"RepoConfigDirPathEnvVar":       RepoConfigDirPathEnvVar,
		"UserConfigDirPathEnvVar":       UserConfigDirPathEnvVar,
		"SystemConfigDirPathEnvVar":     SystemConfigDirPathEnvVar,
		"NoRepoConfigEnvVar":            NoRepoConfigEnvVar,
		"NoUserConfigEnvVar":            NoUserConfigEnvVar,
		"NoSystemConfigEnvVar":          NoSystemConfigEnvVar,
		"StructuredLogsEnvVar":          StructuredLogsEnvVar,
		"DisableReportNewRolloutEnvVar": DisableReportNewRolloutEnvVar,
		"GitRemoteNameEnvVar":           GitRemoteNameEnvVar,
	}

	expected := map[string]string{
		"AutomateURLEnvVar":             "CHEF_AC_AUTOMATE_URL",
		"AutomateTokenEnvVar":           "CHEF_AC_AUTOMATE_TOKEN",
		"AutomateInsecureTLSEnvVar":     "CHEF_AC_AUTOMATE_INSECURE_TLS",
		"RepoConfigDirPathEnvVar":       "CHEF_AC_REPO_CONFIG_DIR",
		"UserConfigDirPathEnvVar":       "CHEF_AC_USER_CONFIG_DIR",
		"SystemConfigDirPathEnvVar":     "CHEF_AC_SYSTEM_CONFIG_DIR",
		"NoRepoConfigEnvVar":            "CHEF_AC_NO_REPO_CONFIG",
		"NoUserConfigEnvVar":            "CHEF_AC_NO_USER_CONFIG",
		"NoSystemConfigEnvVar":          "CHEF_AC_NO_SYSTEM_CONFIG",
		"StructuredLogsEnvVar":          "CHEF_AC_STRUCTURED_LOGS",
		"DisableReportNewRolloutEnvVar": "CHEF_AC_DISABLE_COLLECTOR",
		"GitRemoteNameEnvVar":           "CHEF_AC_GIT_REMOTE_NAME",
	}

	for name, got := range tests {
		if got != expected[name] {
			t.Fatalf("%s: got %q, want %q", name, got, expected[name])
		}
	}

	seen := map[string]string{}
	for name, got := range tests {
		if prev, exists := seen[got]; exists {
			t.Fatalf("duplicate env var value %q used by %s and %s", got, prev, name)
		}
		seen[got] = name
	}
}
