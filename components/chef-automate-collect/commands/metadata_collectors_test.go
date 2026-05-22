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

func BenchmarkGitRemoteNameFromEnv(b *testing.B) {
	benchmarks := []struct {
		name   string
		lookup func(string) (string, bool)
	}{
		{
			name: "unset",
			lookup: func(string) (string, bool) {
				return "", false
			},
		},
		{
			name: "whitespace",
			lookup: func(string) (string, bool) {
				return "   ", true
			},
		},
		{
			name: "trimmed_value",
			lookup: func(string) (string, bool) {
				return " upstream ", true
			},
		},
	}

	for _, benchmark := range benchmarks {
		b.Run(benchmark.name, func(b *testing.B) {
			for b.Loop() {
				_ = gitRemoteNameFromEnv(benchmark.lookup)
			}
		})
	}
}