package commands

import (
	"bytes"
	"context"
	"net/http"
	"time"

	"github.com/pkg/errors"
)

type HTTPResilienceOptions struct {
	MaxAttempts       int
	InitialBackoff    time.Duration
	PerAttemptTimeout time.Duration
	RetryStatusCodes  map[int]bool
	Sleep             func(time.Duration)
}

func doHTTPRequestWithResilience(
	client *http.Client,
	method string,
	url string,
	body []byte,
	headers map[string]string,
	options HTTPResilienceOptions,
	decorateRequest func(*http.Request) *http.Request,
) (*http.Response, error) {
	resolved := withHTTPResilienceDefaults(options)
	var lastErr error

	for attempt := 1; attempt <= resolved.MaxAttempts; attempt++ {
		ctx, cancel := context.WithTimeout(context.Background(), resolved.PerAttemptTimeout)
		req, err := http.NewRequestWithContext(ctx, method, url, bytes.NewReader(body))
		if err != nil {
			cancel()
			return nil, err
		}

		for key, value := range headers {
			req.Header.Set(key, value)
		}

		if decorateRequest != nil {
			req = decorateRequest(req)
		}

		response, err := client.Do(req)
		cancel()

		if err == nil && !resolved.RetryStatusCodes[response.StatusCode] {
			return response, nil
		}

		if err != nil {
			lastErr = err
		} else {
			lastErr = errors.Errorf("request returned retryable status code %d", response.StatusCode)
			_ = response.Body.Close()
		}

		if attempt < resolved.MaxAttempts {
			delay := resolved.InitialBackoff * time.Duration(1<<(attempt-1))
			resolved.Sleep(delay)
		}
	}

	return nil, lastErr
}

func withHTTPResilienceDefaults(options HTTPResilienceOptions) HTTPResilienceOptions {
	resolved := options
	if resolved.MaxAttempts <= 0 {
		resolved.MaxAttempts = 1
	}
	if resolved.InitialBackoff <= 0 {
		resolved.InitialBackoff = 200 * time.Millisecond
	}
	if resolved.PerAttemptTimeout <= 0 {
		resolved.PerAttemptTimeout = 5 * time.Second
	}
	if resolved.RetryStatusCodes == nil {
		resolved.RetryStatusCodes = map[int]bool{}
	}
	if resolved.Sleep == nil {
		resolved.Sleep = time.Sleep
	}
	return resolved
}
