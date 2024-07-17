package keyfetcher

import (
	"flag"
	"fmt"
	"log"
	"os"
	"strings"

	"github.com/chef/chef-licensing/components/go/pkg/api"
	"github.com/chef/chef-licensing/components/go/pkg/spinner"
)

var licenseKeys []string

func GlobalFetchAndPersist() []string {
	// Load the existing licenseKeys from the license file
	for _, key := range licenseFileFetch() {
		appendLicenseKey(key)
	}

	newKeys := fetchFromArg()
	licenseType := validateAndFetchLicenseType(newKeys)
	if licenseType != "" && !HasUnrestrictedLicenseAdded(newKeys, licenseType) {
		appendLicenseKey(newKeys[0])
		return licenseKeys
	}

	newKeys = fetchFromEnv()
	licenseType = validateAndFetchLicenseType(newKeys)
	if licenseType != "" && !HasUnrestrictedLicenseAdded(newKeys, licenseType) {
		appendLicenseKey(newKeys[0])
		return licenseKeys
	}

	// Return keys if license keys are active and not expired or expiring
	// Return keys if there is any error in /client API call, and do not block the flow.
	// Client API possible errors will be handled in software entitlement check call (made after this)
	// client_api_call_error is set to true when there is an error in licenses_active? call
	isActive, startID := isLicenseActive(getLicenseKeys())
	fileClient, _ := api.GetClient().GetLicenseClient(getLicenseKeys(), true)
	if len(getLicenseKeys()) > 0 && isActive && fileClient.IsCommercial() {
		return getLicenseKeys()
	}

	if spinner.IsTTY() {
		newKeys = fetchInteractively(startID)
		if len(newKeys) > 0 {
			licenseClient, _ := api.GetClient().GetLicenseClient(newKeys)
			persistAndConcat(newKeys, licenseClient.LicenseType)
			if (!licenseClient.IsExpired() && !licenseClient.IsExhausted()) || licenseClient.IsCommercial() {
				fmt.Printf("License Key: %s\n", licenseKeys[0])
				return licenseKeys
			}
		}
	} else {
		newKeys = []string{}
	}

	if len(newKeys) == 0 && fileClient != nil && ((!fileClient.IsExpired() && !fileClient.IsExhausted()) || fileClient.IsCommercial()) {
		return licenseKeys
	}

	log.Fatal("Unable to obtain a License Key.")
	return licenseKeys
}

func FetchLicenseType(licenseKeys []string) string {
	client, _ := api.GetClient().GetLicenseClient(licenseKeys)
	return client.LicenseType
}

func getLicenseKeys() []string {
	return licenseKeys
}

func appendLicenseKey(key string) {
	licenseKeys = append(licenseKeys, key)
}

func fetchFromArg() (out []string) {
	var licenseKey string
	flag.StringVar(&licenseKey, "chef-license-key", "", "Chef license key")

	flag.Parse()
	args := flag.Args()
	if len(args) != 0 {
		licenseKey = getFlagArgs(args)
	}
	if licenseKey != "" {
		out = append(out, licenseKey)
	}

	return
}

func getFlagArgs(args []string) string {
	var licensekey string
	for i := 0; i < len(args); i++ {
		if args[i] == "--chef-license-key" {
			if len(args) > i+1 {
				licensekey = args[i+1]
				os.Args = append(os.Args[:i+1], os.Args[i+3:]...)
			} else {
				licensekey = ""
				os.Args = append(os.Args[:i+1], os.Args[i+2:]...)
			}
		} else if strings.Contains(args[i], "--chef-license-key=") {
			checkFlag := strings.Split(args[i], "=")
			if checkFlag[0] == "--chef-license-key" {
				if len(checkFlag[1]) > 0 {
					licensekey = checkFlag[1]
				} else {
					licensekey = ""
				}
				os.Args = append(os.Args[:i+1], os.Args[i+2:]...)
			}
		}
	}
	return licensekey
}

func fetchFromEnv() (out []string) {
	key, ok := os.LookupEnv("CHEF_LICENSE_KEY")
	if ok && key != "" {
		out = append(out, key)
	}

	return
}

func fetchInteractively(startID string) []string {
	return StartInteractions(startID)
}

func validateAndFetchLicenseType(keys []string) (licenseType string) {
	if len(keys) == 0 {
		return
	}
	isValid, _ := api.GetClient().ValidateLicenseAPI(keys[0])
	if isValid {
		licenseType = FetchLicenseType(keys)
	}

	return licenseType
}
