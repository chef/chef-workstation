package telemetry

import (
	"fmt"
	"time"
)

type TelemetryInfo struct {
	Name           string `default:"nil"`
	Origin         string `default:"command-line"`
	ProductVersion string `default:"0.0.0"`
	InstallContext string `default:"omnibus"`
}

var Key = "CHEF_TELEMETRY_ENDPOINT"

func (t TelemetryInfo) Deliver(entry struct {
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
}, tel Telemetry)  {
	if !optOut() {
		var newEvent = Newevent(t)
		payload := map[string]interface{}{}
		payload = newEvent.Prepare(entry, tel)
		eventData := map[string]interface{}{
			"WorkstationVersion": tel.WorkstationVersion,
			"ARCH": tel.Arch,
			"HostOS": tel.HostOs,
		}
		payload["EvantData"] = eventData
		//     client.await.fire(payload)
		fmt.Println("payload-------", payload)
	}
}

func Newevent(t TelemetryInfo) (e Event) {
	e.Product = t.Name
	e.Session = session()
	e.Origin = t.Origin
	e.InstallContext = t.InstallContext
	e.ProductVersion = t.ProductVersion
	return e
}

func session() string {
	return check()
}

// func getEnv(key, defaultValue string) string {
// 	value := os.Getenv(key)
// 	if len(value) == 0 {
// 		return defaultValue
// 	}
// 	return value
// }

// func client(payload) {
// 	endpoint := getEnv("CHEF_TELEMETRY_ENDPOINT", TELEMETRYENDPOINT)
// 	fire(payload, endpoint)
// }
