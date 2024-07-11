package keyfetcher

import (
	"log"
	"os"
	"path/filepath"
	"slices"
	"time"

	"github.com/chef/chef-licensing/components/go/pkg/config"
	"gopkg.in/yaml.v2"
)

const (
	FILE_VERSION = "4.0.0"
)

var LICENSE_TYPES []string = []string{"free", "trial", "commercial"}

type LicenseFileData struct {
	Licenses          []LicenseData `yaml:":licenses"`
	FileFormatVersion string        `yaml:":file_format_version"`
	LicenseServerURL  string        `yaml:":license_server_url"`
}

type LicenseData struct {
	LicenseKey  string `yaml:":license_key"`
	LicenseType string `yaml:":license_type"`
	UpdateTime  string `yaml:":update_time"`
}

func FetchLicenseKeysBasedOnType(licenseType string) (out []string) {
	content := readLicenseKeyFile()
	for _, key := range content.Licenses {
		if key.LicenseType == licenseType {
			out = append(out, key.LicenseKey)
		}
	}
	return
}

func readLicenseKeyFile() *LicenseFileData {
	li := &LicenseFileData{}
	filePath := licenseFilePath()
	info, _ := os.Stat(filePath)
	if info == nil {
		return li
	}

	data, err := (*GetFileHandler()).ReadFile(filePath)
	if err != nil {
		log.Fatal(err)
	}

	err = yaml.Unmarshal(data, &li)
	if err != nil {
		log.Fatal(err)
	}
	return li
}

func licenseFileFetch() []string {
	licenseKey := []string{}
	li := *readLicenseKeyFile()

	for i := 0; i < len(li.Licenses); i++ {
		licenseKey = append(licenseKey, li.Licenses[i].LicenseKey)
	}

	return licenseKey
}

func licenseFilePath() string {
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".chef/licenses.yaml")
}

func persistAndConcat(newKeys []string, licenseType string) {
	if !slices.Contains(LICENSE_TYPES, licenseType) {
		log.Fatal("License type " + licenseType + " is not a valid license type.")
	}

	license := LicenseData{
		LicenseKey:  newKeys[0],
		LicenseType: ":" + licenseType,
		UpdateTime:  time.Now().Format("2006-01-02T15:04:05-07:00"),
	}

	fileContent := readLicenseKeyFile()

	var found bool
	for _, key := range fileContent.Licenses {
		if key.LicenseKey == license.LicenseKey {
			found = true
		}
	}

	if !found {
		fileContent.Licenses = append(fileContent.Licenses, license)
	}
	updateDefaultsOnLicenseFile(fileContent)
	saveLicenseFile(fileContent)
	appendLicenseKey(newKeys[0])
}

func updateDefaultsOnLicenseFile(content *LicenseFileData) {
	if content.FileFormatVersion == "" {
		content.FileFormatVersion = FILE_VERSION
	}

	if content.LicenseServerURL == "" {
		config := config.GetConfig()
		content.LicenseServerURL = config.LicenseServerURL
	}
}

func saveLicenseFile(content *LicenseFileData) {
	filepath := licenseFilePath()

	data, err := yaml.Marshal(&content)
	if err != nil {
		log.Fatalf("error: %v", err)
	}

	err = (*GetFileHandler()).WriteFile(filepath, data, 0644)
	if err != nil {
		log.Fatalf("error: %v", err)
	}
}

func FetchLicenseTypeBasedOnKey(license_keys []string) string {
	content := readLicenseKeyFile()
	var licenseType string
	for _, key := range content.Licenses {
		if key.LicenseKey == license_keys[0] {
			licenseType = key.LicenseType
		}

	}
	return licenseType
}
