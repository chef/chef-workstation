package telemetry

import (
	"log"
	"os"
	"path"
)

func home() string {
	dirname, err := os.UserHomeDir()
	if err != nil {
		log.Fatal(err)
	}
	return dirname
}

var WS_BASE_PATH = path.Join(home(), ".chef-workstation/")

func telemetryPath() string {
	return path.Join(WS_BASE_PATH, "telemetry")
}

func telemetrySessionFile() string {
	return path.Join(telemetryPath(), "TELEMETRY_SESSION_ID")
}

func telemetryInstallationIdentifierFile() string {
	return path.Join(WS_BASE_PATH, "installation_id")
}
