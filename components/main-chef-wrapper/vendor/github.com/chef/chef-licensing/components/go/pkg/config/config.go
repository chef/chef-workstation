package config

type LicenseConfig struct {
	ProductName      string
	EntitlementID    string
	LicenseServerURL string
	ExecutableName   string
}

var cfg *LicenseConfig

func NewConfig(c *LicenseConfig) {
	cfg = c
}

func SetConfig(name, entitlementID, URL, executable string) {
	cfg = &LicenseConfig{
		ProductName:      name,
		EntitlementID:    entitlementID,
		LicenseServerURL: URL,
		ExecutableName:   executable,
	}
}

func GetConfig() *LicenseConfig {
	return cfg
}
