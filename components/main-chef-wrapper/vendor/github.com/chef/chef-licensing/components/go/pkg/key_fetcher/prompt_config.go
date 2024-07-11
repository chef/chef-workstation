package keyfetcher

import _ "embed"

//go:embed interactions.yml
var interactionsYAML []byte

type Interaction struct {
	FileFormatVersion string                  `yaml:":file_format_version"`
	Actions           map[string]ActionDetail `yaml:"interactions"`
}

type TemplateConfig struct {
	ProductName           string
	UnitMeasure           string
	ChefExecutableName    string
	FailureMessage        string
	IsCommercial          bool
	LicenseType           string
	LicenseID             string
	LicenseExpirationDate string
	ExpirationInDays      string
	StartID               string
}

var PromptInput TemplateConfig
