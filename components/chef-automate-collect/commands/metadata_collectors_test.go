package commands

import "testing"

func TestGitRemoteNameFromEnvDefaultsToOriginWhenUnset(t *testing.T) {
	got := gitRemoteNameFromEnv(func(string) (string, bool) {
		return "", false
	})

	if got != "origin" {
		t.Fatalf("got %q, want %q", got, "origin")
	}
}

func TestGitRemoteNameFromEnvIgnoresEmptyValue(t *testing.T) {
	got := gitRemoteNameFromEnv(func(string) (string, bool) {
		return "   ", true
	})

	if got != "origin" {
		t.Fatalf("got %q, want %q", got, "origin")
	}
}

func TestGitRemoteNameFromEnvUsesTrimmedValue(t *testing.T) {
	got := gitRemoteNameFromEnv(func(string) (string, bool) {
		return " upstream ", true
	})

	if got != "upstream" {
		t.Fatalf("got %q, want %q", got, "upstream")
	}
}