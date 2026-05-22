package commands

import "strings"

type featureFlag struct {
	Name           string
	EnvVar         string
	DefaultEnabled bool
}

func featureFlagEnabled(flag featureFlag, lookupEnv func(string) (string, bool), logf func(string, ...interface{})) bool {
	rawValue, isSet := lookupEnv(flag.EnvVar)
	if !isSet {
		logf("feature flag %s (%s) unset; using default=%t", flag.Name, flag.EnvVar, flag.DefaultEnabled)
		return flag.DefaultEnabled
	}

	value := strings.ToLower(strings.TrimSpace(rawValue))
	switch value {
	case "true":
		logf("feature flag %s (%s) resolved=true from value %q", flag.Name, flag.EnvVar, rawValue)
		return true
	case "false":
		logf("feature flag %s (%s) resolved=false from value %q", flag.Name, flag.EnvVar, rawValue)
		return false
	default:
		logf("feature flag %s (%s) has invalid value %q; using default=%t", flag.Name, flag.EnvVar, rawValue, flag.DefaultEnabled)
		return flag.DefaultEnabled
	}
}

var structuredLoggingFlag = featureFlag{
	Name:           "structured_logging",
	EnvVar:         StructuredLogsEnvVar,
	DefaultEnabled: true,
}

var httpVerboseDiagnosticsFlag = featureFlag{
	Name:           "http_verbose_diagnostics",
	EnvVar:         HTTPVerboseDiagnosticsEnvVar,
	DefaultEnabled: false,
}