package keyfetcher

import (
	"slices"

	"github.com/chef/chef-licensing/components/go/pkg/api"
)

func IsLicenseRestricted(licenseType string) (out bool) {
	allowed := allowedLicencesForAddition()
	if !slices.Contains(allowed, licenseType) {
		out = true
	}

	return
}

func DoesUserHasActiveTrialLicense() (out bool) {
	content := *readLicenseKeyFile()
	for _, license := range content.Licenses {
		client, _ := api.GetClient().GetLicenseClient([]string{license.LicenseKey})
		if license.LicenseType == ":trial" && client.IsActive() {
			out = true
		}
	}

	return
}

func HasUnrestrictedLicenseAdded(newKeys []string, licenseType string) bool {
	if IsLicenseRestricted(licenseType) {
		// Existing license keys of same license type are fetched to compare if old license key or a new one is added.
		// However, if user is trying to add Free Tier License, and user has active trial license, we fetch the trial license key
		var existingLicenseKeysInFile []string
		if licenseType == "free" && DoesUserHasActiveTrialLicense() {
			existingLicenseKeysInFile = FetchLicenseKeysBasedOnType(":trial")
		} else if userHasActiveTrialOrFreeLicense() {
			// Handling license addition restriction scenarios only if the current license is an active license
			existingLicenseKeysInFile = FetchLicenseKeysBasedOnType(":" + licenseType)
		}
		// Only prompt when a new trial license is added
		if len(existingLicenseKeysInFile) > 0 {
			if existingLicenseKeysInFile[len(existingLicenseKeysInFile)-1] != newKeys[0] {
				promptLicenseAdditionRestricted(licenseType, existingLicenseKeysInFile)
				return false
			}
		}

		return true
	} else {
		persistAndConcat(newKeys, licenseType)
		return true
	}
}

func allowedLicencesForAddition() []string {
	var license_types = []string{"free", "trial", "commercial"}
	currentTypes := currentLicenseTypes()

	if slices.Contains(currentTypes, ":trial") {
		removeItem(&license_types, "trial")
	}
	if slices.Contains(currentTypes, ":free") || DoesUserHasActiveTrialLicense() {
		removeItem(&license_types, "free")
	}

	return license_types
}
func currentLicenseTypes() (out []string) {
	content := *readLicenseKeyFile()
	for _, license := range content.Licenses {
		out = append(out, license.LicenseType)
	}
	return
}

func removeItem(target *[]string, item string) {
	var out []string
	for _, str := range *target {
		if str != item {
			out = append(out, str)
		}
	}
	*target = out
}
