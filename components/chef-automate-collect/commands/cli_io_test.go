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