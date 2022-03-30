package telemetry

import (
	"fmt"
	"gopkg.in/yaml.v3"
	"io/ioutil"
	"os"
	"path/filepath"
	"runtime"
	"time"
)

const DEFAULT_INSTALLATION_GUID = "00000000-0000-0000-0000-000000000000"

var data = map[string]interface{}{}
var EventsToSend PayloadData
var version = VERSION

type Telemetry struct {
	PayloadDir                 string
	SessionFile                string
	InstallationIdentifierFile string
	Enabled                    bool
	DevMode                    bool
	HostOs                     string
	Arch                       string
	WorkstationVersion         string
}

func (t Telemetry) Setup() {

	// TODO validate required & correct keys
	// payload_dir #required
	// session_file # required
	// installation_identifier_file # required
	// enabled  # false, not required
	// dev_mode # false, not required
	telemetry := t
	startUploadThread(telemetry)
}

func enabled(t Telemetry) bool {
	return t.Enabled && !envOptOut()
}

func (t Telemetry) TimedRunCapture(arguments []int) {
	config := t
	data["arguments"] = arguments
	timedCapture("cli", data, config)
}

func timedCapture(name string, data map[string]interface{}, config Telemetry) {
	//time = Benchmark.measure { yield }
	//data[:duration] = time.real
	data["duration"] = time.Now()
	capture(name, data, config)
}

func capture(name string, data map[string]interface{}, config Telemetry) {
	payload := makeEventPayload(name, data, config)
	EventsToSend = payload
}

func (t Telemetry) Commit() {
	if enabled(t) {
		session := convertEventToSession()
		writeSession(session, t)
	}
	//EventsToSend = []
}

type Entry struct {
	Event string
	Properties struct{
		Installationid string
		RunTimestamp   time.Time
		HostPlatform   string
		EventData      map[string]interface{}
	}
}

type PayloadData struct {
	Version string
	Entries []Entry
}

func makeEventPayload(name string, data map[string]interface{}, config Telemetry) PayloadData {
	payload := PayloadData{
		Version: VERSION,
		Entries: []Entry{
			Entry{
				Event: name,
				Properties: struct {
					Installationid string
					RunTimestamp   time.Time
					HostPlatform   string
					EventData      map[string]interface{}
				}{Installationid: installationId(config), RunTimestamp: time.Now(), HostPlatform: hostPlatform(), EventData: data},
			},
		},
	}
	return payload

}

func installationId(config Telemetry) string {
	content, err := ioutil.ReadFile(config.InstallationIdentifierFile)
	if err != nil {
		return DEFAULT_INSTALLATION_GUID
	}
	return string(content)
}

func hostPlatform() string {
	return runtime.GOOS
}

func convertEventToSession() []byte {
	yamlData, err := yaml.Marshal(&EventsToSend)
	if err != nil {
		// return "error"
	}
	return yamlData
}

func writeSession(session []byte, config Telemetry) {
	err := os.WriteFile(nextFilename(config), convertEventToSession(), 0644)
	if err != nil {
		fmt.Println(err)
	}
}

func nextFilename(config Telemetry) string {
	id := 1
	filename := filepath.Join(config.PayloadDir, fmt.Sprintf("telemetry-payload-%v.yml", id))
	return filename
}
