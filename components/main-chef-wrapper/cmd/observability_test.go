package cmd

import (
	"errors"
	"io"
	"os"
	"strings"
	"testing"
)

func captureStderrForObservability(t *testing.T) (func(), func() string) {
	t.Helper()

	originalStderr := os.Stderr
	r, w, err := os.Pipe()
	if err != nil {
		t.Fatalf("failed to create stderr pipe: %v", err)
	}

	os.Stderr = w

	restore := func() {
		_ = w.Close()
		os.Stderr = originalStderr
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

func TestBuildObservationLineDoesNotLeakArgs(t *testing.T) {
	line := buildObservationLine("push", "/opt/chef-workstation/bin/chef", []string{"push", "POLICY_GROUP", "sensitive-token"}, "start", nil)

	if !strings.Contains(line, "INFO: op=push") {
		t.Fatalf("expected info operation in line, got %q", line)
	}
	if !strings.Contains(line, "target=chef") {
		t.Fatalf("expected target binary name in line, got %q", line)
	}
	if !strings.Contains(line, "argc=3") {
		t.Fatalf("expected argument count in line, got %q", line)
	}
	if strings.Contains(line, "sensitive-token") {
		t.Fatalf("expected args to remain redacted from line, got %q", line)
	}
}

func TestEmitCommandObservationWritesConsistentInfoLine(t *testing.T) {
	restore, readOutput := captureStderrForObservability(t)
	emitCommandObservation("push_archive", "/usr/local/bin/chef", []string{"push-archive", "group", "archive.tgz"}, "success", nil)
	restore()

	got := readOutput()
	t.Logf("sample-observation-line: %s", got)
	if !strings.HasPrefix(got, "INFO: op=push_archive target=chef argc=3 status=success") {
		t.Fatalf("unexpected observation line: %q", got)
	}
}

func TestEmitCommandObservationIncludesErrorDetails(t *testing.T) {
	restore, readOutput := captureStderrForObservability(t)
	emitCommandObservation("push_rollout_report", "automate-collect", []string{"report-new-rollout"}, "error", errors.New("command failed"))
	restore()

	got := readOutput()
	if !strings.Contains(got, "status=error") {
		t.Fatalf("expected status=error in observation line, got %q", got)
	}
	if !strings.Contains(got, `error="command failed"`) {
		t.Fatalf("expected error details in observation line, got %q", got)
	}
}
