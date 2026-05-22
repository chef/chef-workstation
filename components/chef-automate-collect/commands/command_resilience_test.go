package commands

import (
	"context"
	"errors"
	"strings"
	"testing"
	"time"
)

func TestExecuteCommandWithResilienceRetriesOnErrorThenSucceeds(t *testing.T) {
	attempts := 0
	sleeps := 0

	executor := func(context.Context, string, ...string) (string, error) {
		attempts++
		if attempts < 3 {
			return "", errors.New("temporary failure")
		}
		return "ok", nil
	}

	output, err := executeCommandWithResilience(executor, "git", []string{"status"}, CommandResilienceOptions{
		MaxAttempts:       3,
		InitialBackoff:    1 * time.Millisecond,
		PerAttemptTimeout: 50 * time.Millisecond,
		Sleep: func(time.Duration) {
			sleeps++
		},
	})

	if err != nil {
		t.Fatalf("expected success after retries, got %v", err)
	}
	if output != "ok" {
		t.Fatalf("got %q, want %q", output, "ok")
	}
	if attempts != 3 {
		t.Fatalf("got %d attempts, want 3", attempts)
	}
	if sleeps != 2 {
		t.Fatalf("got %d sleeps, want 2", sleeps)
	}
}

func TestExecuteCommandWithResilienceReturnsErrorAfterExhaustion(t *testing.T) {
	executor := func(context.Context, string, ...string) (string, error) {
		return "", errors.New("still failing")
	}

	_, err := executeCommandWithResilience(executor, "git", []string{"status"}, CommandResilienceOptions{
		MaxAttempts:       2,
		InitialBackoff:    1 * time.Millisecond,
		PerAttemptTimeout: 50 * time.Millisecond,
		Sleep:             func(time.Duration) {},
	})

	if err == nil {
		t.Fatal("expected non-nil error after retries exhausted")
	}
	if !strings.Contains(err.Error(), "attempt 2") {
		t.Fatalf("expected final attempt in error, got %q", err.Error())
	}
}

func TestExecuteCommandWithResilienceHandlesTimeouts(t *testing.T) {
	attempts := 0

	executor := func(ctx context.Context, _ string, _ ...string) (string, error) {
		attempts++
		<-ctx.Done()
		return "", ctx.Err()
	}

	_, err := executeCommandWithResilience(executor, "git", []string{"status"}, CommandResilienceOptions{
		MaxAttempts:       3,
		InitialBackoff:    1 * time.Millisecond,
		PerAttemptTimeout: 1 * time.Millisecond,
		Sleep:             func(time.Duration) {},
	})

	if err == nil {
		t.Fatal("expected timeout error")
	}
	if attempts != 3 {
		t.Fatalf("got %d attempts, want 3", attempts)
	}
	if !strings.Contains(err.Error(), "context deadline exceeded") {
		t.Fatalf("expected timeout context in error, got %q", err.Error())
	}
}
