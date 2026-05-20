package commands

import "testing"

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
