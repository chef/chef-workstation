package keyfetcher

import (
	"fmt"
	"regexp"
	"strconv"
	"time"

	"github.com/chef/chef-licensing/components/go/pkg/api"
	"github.com/chef/chef-licensing/components/go/pkg/spinner"
)

const (
	LICENSE_KEY_REGEX        = `^([a-z]{4}-[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}-[0-9]{1,4})$`
	LICENSE_KEY_PATTERN_DESC = "Hexadecimal"
	SERIAL_KEY_REGEX         = `^([A-Z0-9]{26})$`
	SERIAL_KEY_PATTERN_DESC  = "26 character alphanumeric string"
	COMMERCIAL_KEY_REGEX     = `^([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12})$`
	QUIT_KEY_REGEX           = "(q|Q)"
)

var ErrInvalidKeyFormat = fmt.Errorf(fmt.Sprintf("Malformed License Key passed on command line - should be %s or %s", LICENSE_KEY_PATTERN_DESC, SERIAL_KEY_PATTERN_DESC))

func ValidateKeyFormat(key string) (matches bool) {
	var regexes []*regexp.Regexp
	patterns := []string{LICENSE_KEY_REGEX, SERIAL_KEY_REGEX, COMMERCIAL_KEY_REGEX}

	for _, pattern := range patterns {
		regex := regexp.MustCompile(pattern)
		regexes = append(regexes, regex)
	}

	for _, regex := range regexes {
		if regex.MatchString(key) {
			matches = true
			break
		}
	}

	return
}

func promptLicenseAdditionRestricted(licenseType string, existingLicenseKeysInFile []string) {
	// fmt.Printf("License Key fetcher - prompting license addition restriction\n")
	UpdatePromptInputs(map[string]string{
		"LicenseID":   existingLicenseKeysInFile[len(existingLicenseKeysInFile)-1],
		"LicenseType": licenseType,
	})
	StartInteractions("prompt_license_addition_restriction")
}

func isLicenseActive(keys []string) (out bool, promptStartID string) {
	conf := make(map[string]string)
	if len(keys) == 0 {
		return
	}

	spinner, err := spinner.GetSpinner()
	if err != nil {
		fmt.Printf("Unable to start the spinner\n")
	}
	_ = spinner.Start()
	spinner.Message("In progress")

	licenseClient, _ := api.GetClient().GetLicenseClient(keys)
	if licenseClient == nil {
		return false, ""
	}

	// Intentional lag of 2 seconds when license is expiring or expired
	if licenseClient.IsExpiringOrExpired() {
		time.Sleep(2 * time.Second)
	}

	if licenseClient.IsExpired() || licenseClient.HaveGrace() {
		promptStartID = "prompt_license_expired"
		out = false
	} else if licenseClient.IsAboutToExpire() {
		promptStartID = "prompt_license_about_to_expire"
		out = false
		conf["ExpirationInDays"] = strconv.Itoa(licenseClient.ExpirationInDays())
		conf["LicenseExpirationDate"] = licenseClient.LicenseExpirationDate().Format(time.UnixDate)
	} else if licenseClient.IsExhausted() && (licenseClient.IsCommercial() || licenseClient.IsFree()) {
		promptStartID = "prompt_license_exhausted"
		out = false
	} else {
		// If license is not expired or expiring, return true. But if the license is not commercial, warn the user.
		if !licenseClient.IsCommercial() {
			promptStartID = "warn_non_commercial_license"
		}
		out = true
	}
	if out {
		spinner.StopCharacter("✓")
		spinner.StopColors("green")
	} else {
		spinner.StopCharacter("X")
		spinner.StopColors("red")
	}

	time.Sleep(2 * time.Second)
	spinner.Message("Done")
	_ = spinner.Stop()
	cacheClientToPromptInput(licenseClient, conf)

	return out, promptStartID
}

func cacheClientToPromptInput(client *api.LicenseClient, conf map[string]string) {
	conf["LicenseType"] = client.LicenseType
	UpdatePromptInputs(conf)
}
