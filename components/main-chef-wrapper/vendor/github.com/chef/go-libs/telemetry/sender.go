package telemetry

import (
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path"
	"path/filepath"
	"time"

	"gopkg.in/yaml.v3"
)

type TelemetryPayload struct {
	Version string `yaml:"version"`
	Entries []struct {
		Event      string `yaml:"event"`
		Properties struct {
			InstallationID string    `yaml:"installationid"`
			RunTimestamp   time.Time `yaml:"runtimestamp"`
			HostPlatform   string    `yaml:"hostplatform"`
			EventData      struct {
				Arguments []string `yaml:"arguments"`
				Duration  float64  `yaml:"duration"`
			} `yaml:"event_data"`
		} `yaml:"properties"`
	} `yaml:"entries"`
}


func startUploadThread(t Telemetry) {
	// Find the files before we spawn the thread - otherwise
	// we may accidentally pick up the current run's session file if it
	// finishes before the thread scans for new files
	sessionFiles := findSessionFiles(t)
	// Thread.new{sender.run}
	run(t, sessionFiles)

}

func findSessionFiles(t Telemetry) []string {
	sessionSearch := path.Join(t.PayloadDir, "telemetry-payload-*.yml")
	sessionFiles, _ := filepath.Glob(sessionSearch)
	return sessionFiles

}

func run(t Telemetry, sessionFiles []string) {
	if enabled(t) {
		if t.DevMode {
			os.Setenv("CHEF_TELEMETRY_ENDPOINT", "https://telemetry-acceptance.chef.io")
		}
		for i := 0; i < len(sessionFiles); i++ {
			processSession(sessionFiles[i], t)
		}

	} else {
		// If telemetry is not enabled, just clean up and return. Even though
		// the telemetry gem will not send if disabled, log output saying that we're submitting
		// it when it has been disabled can be alarming.
		fmt.Println("Telemetry disabled, clearing any existing session captures without sending them.")
		for i := 0; i < len(sessionFiles); i++ {
			err := os.RemoveAll(sessionFiles[i])
			if err != nil {
				log.Fatal(err)
			}
		}
	}
	err := os.RemoveAll(t.SessionFile)
	if err != nil {
		log.Fatal(err)
	}
	fmt.Println("Terminating, nothing more to do.")
}

func processSession(sessionFilePath string, t Telemetry) {
	fmt.Println("Processing telemetry entries from")
	content := loadAndClearSession(sessionFilePath)
	submitSession(content, t)

}

func NewTelemetryInfo(content TelemetryPayload) (t TelemetryInfo) {
	t.Name = "chef-workstation"
	t.Origin = "command-line"
	t.ProductVersion = content.Version
	t.InstallContext = "omnibus"
	return t

}

func submitSession(content TelemetryPayload, t Telemetry) {

	// Each file contains the actions taken within a single run of the chef tool.
	// Each run is one session, so we'll first remove remove the session file
	// to force creating a new one.
	err := os.RemoveAll(t.SessionFile)
	if err != nil {
		log.Fatal(err)
	}
	// We'll use the version captured in the sesion file
	entries := content.Entries
	var newTelemetry = NewTelemetryInfo(content)
	total := len(entries)
	for index, element := range entries {
		fmt.Println("Submitting telemetry entry #{sequence}/#{total}: #{entry} ")
		submitEntry(newTelemetry, element, index+1, total, t)
	}

}

func submitEntry(newTelemetry TelemetryInfo, entry struct {
	Event      string `yaml:"event"`
	Properties struct {
		InstallationID string    `yaml:"installationid"`
		RunTimestamp   time.Time `yaml:"runtimestamp"`
		HostPlatform   string    `yaml:"hostplatform"`
		EventData      struct {
			Arguments []string `yaml:"arguments"`
			Duration  float64  `yaml:"duration"`
		} `yaml:"event_data"`
	} `yaml:"properties"`
}, sequence, total int, tel Telemetry) {
	newTelemetry.Deliver(entry, tel)
}

func loadAndClearSession(sessionFilePath string) TelemetryPayload {
	filename, _ := filepath.Abs(sessionFilePath)
	yfile, err := ioutil.ReadFile(filename)
	var config TelemetryPayload

	if err != nil {

		log.Fatal(err)
	}
	err2 := yaml.Unmarshal(yfile, &config)

	if err2 != nil {

		log.Fatal(err2)
	}
	return config
}
