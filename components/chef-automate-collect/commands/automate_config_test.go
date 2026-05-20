package commands

import (
	"strings"
	"testing"
)

func TestRedactSecretForLogRedactsNonEmptySecrets(t *testing.T) {
	secret := "super-secret-token"
	got := redactSecretForLog(secret)

	if got == secret {
		t.Fatalf("got raw secret %q, expected redacted value", got)
	}
	if got != "[REDACTED]" {
		t.Fatalf("got %q, want %q", got, "[REDACTED]")
	}
}

func TestRedactSecretForLogKeepsEmptyValueEmpty(t *testing.T) {
	got := redactSecretForLog("")

	if got != "" {
		t.Fatalf("got %q, want empty string", got)
	}
}

func TestMapTestConfigHTTPErrorWithoutBody(t *testing.T) {
	err := mapTestConfigHTTPError("https://automate.example", 503, "")

	if err == nil {
		t.Fatal("expected an error for non-200 response")
	}

	want := "request to \"https://automate.example\" failed with status code 503"
	if err.Error() != want {
		t.Fatalf("got %q, want %q", err.Error(), want)
	}
}

func TestMapTestConfigHTTPErrorWithBodyTruncatesLongBody(t *testing.T) {
	longBody := strings.Repeat("x", 300)
	err := mapTestConfigHTTPError("https://automate.example", 500, longBody)

	if err == nil {
		t.Fatal("expected an error for non-200 response")
	}

	message := err.Error()
	if !strings.Contains(message, "status code 500") {
		t.Fatalf("expected status code in message, got %q", message)
	}
	if !strings.Contains(message, "...") {
		t.Fatalf("expected truncated suffix in message, got %q", message)
	}
	if strings.Count(message, "x") < 200 {
		t.Fatalf("expected truncated body content in message, got %q", message)
	}
}
