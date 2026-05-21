package commands

import (
	"io/ioutil"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
	"time"
)

type roundTripFunc func(*http.Request) (*http.Response, error)

func (f roundTripFunc) RoundTrip(req *http.Request) (*http.Response, error) {
	return f(req)
}

func TestDoHTTPRequestWithResilienceRetriesRetryableStatus(t *testing.T) {
	attempts := 0
	sleeps := 0

	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		attempts++
		if attempts < 3 {
			w.WriteHeader(http.StatusServiceUnavailable)
			_, _ = w.Write([]byte("try again"))
			return
		}
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte("ok"))
	}))
	defer server.Close()

	resp, err := doHTTPRequestWithResilience(
		http.DefaultClient,
		"GET",
		server.URL,
		nil,
		nil,
		HTTPResilienceOptions{
			MaxAttempts:       3,
			InitialBackoff:    1 * time.Millisecond,
			PerAttemptTimeout: 1 * time.Second,
			RetryStatusCodes:  map[int]bool{503: true},
			Sleep: func(time.Duration) {
				sleeps++
			},
		},
		nil,
	)

	if err != nil {
		t.Fatalf("expected success after retries, got error: %v", err)
	}
	defer func() {
		_ = resp.Body.Close()
	}()

	if resp.StatusCode != http.StatusOK {
		t.Fatalf("unexpected status code: got %d want %d", resp.StatusCode, http.StatusOK)
	}
	if attempts != 3 {
		t.Fatalf("unexpected attempt count: got %d want 3", attempts)
	}
	if sleeps != 2 {
		t.Fatalf("unexpected sleep count: got %d want 2", sleeps)
	}
}

func TestDoHTTPRequestWithResilienceRetriesTimeoutLikeErrors(t *testing.T) {
	attempts := 0
	client := &http.Client{Transport: roundTripFunc(func(*http.Request) (*http.Response, error) {
		attempts++
		return nil, contextDeadlineExceededError{}
	})}

	resp, err := doHTTPRequestWithResilience(
		client,
		"GET",
		"https://example.test",
		nil,
		nil,
		HTTPResilienceOptions{
			MaxAttempts:       3,
			InitialBackoff:    1 * time.Millisecond,
			PerAttemptTimeout: 10 * time.Millisecond,
			Sleep:             func(time.Duration) {},
		},
		nil,
	)

	if err == nil {
		t.Fatal("expected error after retry exhaustion")
	}
	if resp != nil {
		t.Fatalf("expected nil response on repeated transport error, got status %d", resp.StatusCode)
	}
	if attempts != 3 {
		t.Fatalf("unexpected attempt count: got %d want 3", attempts)
	}
}

func TestDoHTTPRequestWithResilienceSetsPerAttemptTimeout(t *testing.T) {
	client := &http.Client{Transport: roundTripFunc(func(req *http.Request) (*http.Response, error) {
		deadline, ok := req.Context().Deadline()
		if !ok {
			t.Fatal("expected request context deadline")
		}
		if time.Until(deadline) <= 0 {
			t.Fatal("expected positive timeout window")
		}
		return &http.Response{
			StatusCode: http.StatusOK,
			Body:       ioutil.NopCloser(strings.NewReader("ok")),
			Header:     make(http.Header),
		}, nil
	})}

	resp, err := doHTTPRequestWithResilience(
		client,
		"GET",
		"https://example.test",
		nil,
		nil,
		HTTPResilienceOptions{PerAttemptTimeout: 50 * time.Millisecond},
		nil,
	)

	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}
	if resp == nil || resp.StatusCode != http.StatusOK {
		t.Fatalf("unexpected response: %#v", resp)
	}
	_ = resp.Body.Close()
}

type contextDeadlineExceededError struct{}

func (contextDeadlineExceededError) Error() string {
	return "context deadline exceeded"
}
