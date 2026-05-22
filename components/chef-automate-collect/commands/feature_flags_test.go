package commands

import "testing"

func TestFeatureFlagEnabledDefaultsWhenUnset(t *testing.T) {
	flag := featureFlag{Name: "sample", EnvVar: "CHEF_AC_FF_SAMPLE", DefaultEnabled: false}
	got := featureFlagEnabled(flag, func(string) (string, bool) {
		return "", false
	}, func(string, ...interface{}) {})

	if got {
		t.Fatal("expected default false when env var is unset")
	}
}

func TestFeatureFlagEnabledResolvesTrue(t *testing.T) {
	flag := featureFlag{Name: "sample", EnvVar: "CHEF_AC_FF_SAMPLE", DefaultEnabled: false}
	got := featureFlagEnabled(flag, func(string) (string, bool) {
		return " true ", true
	}, func(string, ...interface{}) {})

	if !got {
		t.Fatal("expected true when env var is true")
	}
}

func TestFeatureFlagEnabledResolvesFalse(t *testing.T) {
	flag := featureFlag{Name: "sample", EnvVar: "CHEF_AC_FF_SAMPLE", DefaultEnabled: true}
	got := featureFlagEnabled(flag, func(string) (string, bool) {
		return "false", true
	}, func(string, ...interface{}) {})

	if got {
		t.Fatal("expected false when env var is false")
	}
}

func TestFeatureFlagEnabledFallsBackOnInvalidValue(t *testing.T) {
	flag := featureFlag{Name: "sample", EnvVar: "CHEF_AC_FF_SAMPLE", DefaultEnabled: true}
	got := featureFlagEnabled(flag, func(string) (string, bool) {
		return "sometimes", true
	}, func(string, ...interface{}) {})

	if !got {
		t.Fatal("expected default true when env var value is invalid")
	}
}
