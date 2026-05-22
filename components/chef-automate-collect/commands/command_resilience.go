package commands

import (
	"context"
	"os/exec"
	"strings"
	"time"

	"github.com/pkg/errors"
)

type CommandResilienceOptions struct {
	MaxAttempts       int
	InitialBackoff    time.Duration
	PerAttemptTimeout time.Duration
	Sleep             func(time.Duration)
}

type commandExecutor func(ctx context.Context, name string, args ...string) (string, error)

func executeCommandWithResilience(
	executor commandExecutor,
	name string,
	args []string,
	options CommandResilienceOptions,
) (string, error) {
	resolved := withCommandResilienceDefaults(options)
	var lastErr error

	for attempt := 1; attempt <= resolved.MaxAttempts; attempt++ {
		ctx, cancel := context.WithTimeout(context.Background(), resolved.PerAttemptTimeout)
		output, err := executor(ctx, name, args...)
		cancel()

		if err == nil {
			return output, nil
		}

		lastErr = errors.Wrapf(err, "command %q failed on attempt %d", name, attempt)
		if attempt < resolved.MaxAttempts {
			delay := resolved.InitialBackoff * time.Duration(1<<(attempt-1))
			resolved.Sleep(delay)
		}
	}

	return "", lastErr
}

func withCommandResilienceDefaults(options CommandResilienceOptions) CommandResilienceOptions {
	resolved := options
	if resolved.MaxAttempts <= 0 {
		resolved.MaxAttempts = 3
	}
	if resolved.InitialBackoff <= 0 {
		resolved.InitialBackoff = 100 * time.Millisecond
	}
	if resolved.PerAttemptTimeout <= 0 {
		resolved.PerAttemptTimeout = 2 * time.Second
	}
	if resolved.Sleep == nil {
		resolved.Sleep = time.Sleep
	}
	return resolved
}

func runCommand(ctx context.Context, name string, args ...string) (string, error) {
	cmd := exec.CommandContext(ctx, name, args...)
	out, err := cmd.CombinedOutput()
	if err != nil {
		trimmed := strings.TrimSpace(string(out))
		if trimmed == "" {
			return "", err
		}
		return "", errors.Wrap(err, trimmed)
	}

	return string(out), nil
}
