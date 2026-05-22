package commands

import (
	"io"
	"net/http"
	"net/http/httptest"
	"os"
	"strings"
	"testing"
	"time"
)

func captureStderrForTestConfig(t *testing.T) (func(), func() string) {
	t.Helper()

	origStderr := os.Stderr
	r, w, err := os.Pipe()
	if err != nil {
		t.Fatalf("failed to create stderr pipe: %v", err)
	}

	os.Stderr = w

	restore := func() {
		_ = w.Close()
		os.Stderr = origStderr
	}

	readOutput := func() string {
		b, err := io.ReadAll(r)
		if err != nil {
			t.Fatalf("failed to read stderr output: %v", err)
		}
		_ = r.Close()
		return string(b)
	}

	return restore, readOutput
}

func TestAutomateConfigTestEmitsStructuredHTTPLog(t *testing.T) {
	server := httptest.NewTLSServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path != TestCreateURLPath {
			t.Fatalf("unexpected path: got %q want %q", r.URL.Path, TestCreateURLPath)
		}
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"ok":true}`))
	}))
	defer server.Close()

	c := &AutomateConfig{
		URL:         server.URL,
		authToken:   "test-token-not-secret",
		InsecureTLS: true,
	}

	originalVerbose := cliIO.EnableVerbose
	cliIO.EnableVerbose = true
	defer func() {
		cliIO.EnableVerbose = originalVerbose
	}()

	t.Setenv(StructuredLogsEnvVar, "true")

	restore, readOutput := captureStderrForTestConfig(t)
	err := c.Test()
	restore()
	output := readOutput()

	if err != nil {
		t.Fatalf("expected test-config request to succeed, got error: %v", err)
	}

	t.Logf("captured structured output: %s", strings.TrimSpace(output))

	if !strings.Contains(output, "op=test_config_http") {
		t.Fatalf("expected structured op field in output, got %q", output)
	}
	if !strings.Contains(output, "status=success") {
		t.Fatalf("expected success status field in output, got %q", output)
	}
	if !strings.Contains(output, "status_code=200") {
		t.Fatalf("expected status_code field in output, got %q", output)
	}
}

func TestAutomateConfigTestRetriesTransientServerError(t *testing.T) {
	hits := 0
	server := httptest.NewTLSServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		hits++
		if hits == 1 {
			w.WriteHeader(http.StatusServiceUnavailable)
			_, _ = w.Write([]byte(`{"error":"temporary"}`))
			return
		}
		w.WriteHeader(http.StatusOK)
		_, _ = w.Write([]byte(`{"ok":true}`))
	}))
	defer server.Close()

	originalOptions := testConfigHTTPResilienceOptions
	testConfigHTTPResilienceOptions.InitialBackoff = 1 * time.Millisecond
	t.Cleanup(func() {
		testConfigHTTPResilienceOptions = originalOptions
	})

	c := &AutomateConfig{
		URL:         server.URL,
		authToken:   "test-token-not-secret",
		InsecureTLS: true,
	}

	err := c.Test()
	if err != nil {
		t.Fatalf("expected retry to recover from transient error, got: %v", err)
	}
	if hits != 2 {
		t.Fatalf("expected exactly one retry, got %d requests", hits)
	}
}

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

func TestPrivateConfigIsAutomateCollectorConfig(t *testing.T) {
	pc := &PrivateConfig{Automate: &PrivateAutomateConfig{}}
	if !pc.IsAutomateCollectorConfig() {
		t.Fatal("expected PrivateConfig.IsAutomateCollectorConfig() to return true")
	}
}

func TestConfigIsAutomateCollectorConfig(t *testing.T) {
	c := &Config{Automate: &AutomateConfig{}}
	if !c.IsAutomateCollectorConfig() {
		t.Fatal("expected Config.IsAutomateCollectorConfig() to return true")
	}
}

func TestPrivateConfigToConfigPreservesAutomateConfig(t *testing.T) {
	pac := &PrivateAutomateConfig{
		AutomateConfig: &AutomateConfig{
			URL:         "https://automate.example",
			authToken:   "secret-token",
			InsecureTLS: true,
		},
		AuthToken:   "secret-token",
		InsecureTLS: true,
	}
	pc := &PrivateConfig{Automate: pac}

	result := pc.ToConfig()

	if result == nil {
		t.Fatal("expected non-nil Config result")
	}
	if result.Automate == nil {
		t.Fatal("expected non-nil Automate config in result")
	}
	if result.Automate.URL != "https://automate.example" {
		t.Fatalf("expected URL %q, got %q", "https://automate.example", result.Automate.URL)
	}
	if result.Automate.authToken != "secret-token" {
		t.Fatalf("expected authToken %q, got %q", "secret-token", result.Automate.authToken)
	}
	if !result.Automate.InsecureTLS {
		t.Fatal("expected InsecureTLS to be true")
	}
}

func TestPrivateAutomateConfigToConfigConvertsProperly(t *testing.T) {
	pac := &PrivateAutomateConfig{
		AutomateConfig: &AutomateConfig{
			URL:         "https://automate.example",
			authToken:   "old-token",
			InsecureTLS: false,
		},
		AuthToken:   "new-token",
		InsecureTLS: true,
	}

	result := pac.ToConfig()

	if result == nil {
		t.Fatal("expected non-nil AutomateConfig result")
	}
	if result.URL != "https://automate.example" {
		t.Fatalf("expected URL %q, got %q", "https://automate.example", result.URL)
	}
	// AuthToken and InsecureTLS should be overwritten from PrivateAutomateConfig
	if result.authToken != "new-token" {
		t.Fatalf("expected authToken %q, got %q", "new-token", result.authToken)
	}
	if !result.InsecureTLS {
		t.Fatal("expected InsecureTLS to be true after conversion")
	}
}

func TestViableConfigPathsFiltersEmptyPaths(t *testing.T) {
	loader := &ConfigLoader{
		SystemConfigPath:    "/etc/automate.toml",
		UserConfigPath:      "", // empty, should be filtered
		RepoConfigPath:      ".automate/config.toml",
		RepoPrivateConfigPath: "",  // empty, should be filtered
	}

	result := loader.ViableConfigPaths()

	if len(result) != 2 {
		t.Fatalf("expected 2 paths after filtering, got %d", len(result))
	}
	if result[0] != "/etc/automate.toml" {
		t.Fatalf("expected first path %q, got %q", "/etc/automate.toml", result[0])
	}
	if result[1] != ".automate/config.toml" {
		t.Fatalf("expected second path %q, got %q", ".automate/config.toml", result[1])
	}
}
