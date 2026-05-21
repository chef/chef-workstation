package cmd

import (
	"io"
	"os"
	"strings"
	"testing"
)

func captureStderrForRolloutValidation(t *testing.T) (func(), func() string) {
	t.Helper()

	origStderr := os.Stderr
	r, w, err := os.Pipe()
	if err != nil {
		t.Fatalf("failed to create stderr pipe: %v", err)
	}

	os.Stderr = w

	restore := func() {
		_ = w.Close()
		os.Stderr = origStderr
	}

	readOutput := func() string {
		b, err := io.ReadAll(r)
		if err != nil {
			t.Fatalf("failed to read stderr output: %v", err)
		}
		_ = r.Close()
		return strings.TrimSpace(string(b))
	}

	return restore, readOutput
}

func setValidRolloutEnv(t *testing.T) {
	t.Helper()
	t.Setenv("CHEF_AC_SERVER_URL", "https://example-chef-server")
	t.Setenv("CHEF_AC_SERVER_USER", "test-user")
	t.Setenv("CHEF_AC_AUTOMATE_URL", "https://example-automate")
	t.Setenv("CHEF_AC_AUTOMATE_TOKEN", "token-value")
}

func TestValidateRolloutSetupContract(t *testing.T) {
	t.Run("returns true when all required vars exist", func(t *testing.T) {
		setValidRolloutEnv(t)

		restore, readOutput := captureStderrForRolloutValidation(t)
		got := ValidateRolloutSetup()
		restore()
		stderr := readOutput()

		if !got {
			t.Fatalf("expected rollout setup validation to pass when all vars are set")
		}
		if stderr != "" {
			t.Fatalf("expected empty stderr when validation passes, got %q", stderr)
		}
	})

	tests := []struct {
		name         string
		missingVar   string
		expectStderr string
	}{
		{
			name:         "missing CHEF_AC_SERVER_URL",
			missingVar:   "CHEF_AC_SERVER_URL",
			expectStderr: "ERROR: CHEF_AC_SERVER_URL environment variable must be set for rollout reporting",
		},
		{
			name:         "missing CHEF_AC_SERVER_USER",
			missingVar:   "CHEF_AC_SERVER_USER",
			expectStderr: "ERROR: CHEF_AC_SERVER_USER environment variable must be set for rollout reporting",
		},
		{
			name:         "missing CHEF_AC_AUTOMATE_URL",
			missingVar:   "CHEF_AC_AUTOMATE_URL",
			expectStderr: "ERROR: CHEF_AC_AUTOMATE_URL environment variable must be set for rollout reporting",
		},
		{
			name:         "missing CHEF_AC_AUTOMATE_TOKEN",
			missingVar:   "CHEF_AC_AUTOMATE_TOKEN",
			expectStderr: "ERROR: CHEF_AC_AUTOMATE_TOKEN environment variable must be set for rollout reporting",
		},
	}

	for _, tc := range tests {
		t.Run(tc.name, func(t *testing.T) {
			setValidRolloutEnv(t)
			t.Setenv(tc.missingVar, "")

			restore, readOutput := captureStderrForRolloutValidation(t)
			got := ValidateRolloutSetup()
			restore()
			stderr := readOutput()

			if got {
				t.Fatalf("expected rollout setup validation to fail when %s is missing", tc.missingVar)
			}
			if stderr != tc.expectStderr {
				t.Fatalf("contract mismatch for %s\nexpected: %q\nactual:   %q", tc.missingVar, tc.expectStderr, stderr)
			}
		})
	}
}
