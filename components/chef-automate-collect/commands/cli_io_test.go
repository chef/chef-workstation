package commands

import (
	"io"
	"os"
	"strings"
	"testing"
	"time"
)

func captureStderrForStructuredVerbose(t *testing.T) (func(), func() string) {
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
		return string(b)
	}

	return restore, readOutput
}

func BenchmarkStructuredLogLine(b *testing.B) {
	fields := []StructuredField{
		{Key: "config_paths", Value: "3"},
		{Key: "source", Value: "repo"},
		{Key: "result", Value: "ok"},
		{Key: "module", Value: "automate_config"},
	}

	b.ReportAllocs()
	b.ResetTimer()

	for i := 0; i < b.N; i++ {
		_ = structuredLogLine("config_load", "success", 37*time.Millisecond, fields...)
	}
}

func TestStructuredLogLineIncludesRequiredFields(t *testing.T) {
	got := structuredLogLine("config_load", "success", 12*time.Millisecond,
		StructuredField{Key: "config_paths", Value: "2"})

	want := "op=config_load status=success elapsed_ms=12 config_paths=2"
	if got != want {
		t.Fatalf("got %q, want %q", got, want)
	}
}

func TestStructuredLogLinePreservesFieldOrder(t *testing.T) {
	got := structuredLogLine("config_load", "error", 3*time.Millisecond,
		StructuredField{Key: "path", Value: "config.toml"},
		StructuredField{Key: "error", Value: "decode_toml"})

	want := "op=config_load status=error elapsed_ms=3 path=config.toml error=decode_toml"
	if got != want {
		t.Fatalf("got %q, want %q", got, want)
	}
}

func TestStructuredLoggingEnabledDefaultsOn(t *testing.T) {
	got := structuredLoggingEnabled(func(string) (string, bool) {
		return "", false
	})

	if !got {
		t.Fatal("expected structured logging to be enabled when env var is unset")
	}
}

func TestStructuredLoggingEnabledTurnsOff(t *testing.T) {
	got := structuredLoggingEnabled(func(string) (string, bool) {
		return "false", true
	})

	if got {
		t.Fatal("expected structured logging to be disabled when env var is false")
	}
}

func TestStructuredLoggingEnabledTurnsOn(t *testing.T) {
	got := structuredLoggingEnabled(func(string) (string, bool) {
		return "true", true
	})

	if !got {
		t.Fatal("expected structured logging to be enabled when env var is true")
	}
}

func TestStructuredVerboseHonorsProcessEnvToggle(t *testing.T) {
	originalVerbose := cliIO.EnableVerbose
	cliIO.EnableVerbose = true
	defer func() {
		cliIO.EnableVerbose = originalVerbose
	}()

	restore, readOutput := captureStderrForStructuredVerbose(t)
	cliIO.structuredVerbose(
		"config_load",
		"success",
		5*time.Millisecond,
		StructuredField{Key: "config_paths", Value: "1"},
	)
	restore()

	output := strings.TrimSpace(readOutput())
	value, isSet := os.LookupEnv(StructuredLogsEnvVar)
	enabled := !isSet || strings.TrimSpace(value) != "false"

	t.Logf("%s=%q enabled=%t output=%q", StructuredLogsEnvVar, value, enabled, output)

	if enabled {
		if !strings.Contains(output, "op=config_load") {
			t.Fatalf("expected structured log output when flag is enabled, got %q", output)
		}
		return
	}

	if output != "" {
		t.Fatalf("expected no structured output when flag is disabled, got %q", output)
	}
}
