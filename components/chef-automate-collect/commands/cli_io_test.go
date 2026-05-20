package commands

import (
	"testing"
	"time"
)

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