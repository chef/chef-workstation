package telemetry

import (
	"fmt"
)

type TelemetryInfo struct {
	Name           string `default:"nil"`
	Origin         string `default:"command-line"`
	ProductVersion string `default:"0.0.0"`
	InstallContext string `default:"omnibus"`
}

var Key = "CHEF_TELEMETRY_ENDPOINT"

func (t TelemetryInfo) Deliver(entry EventEntry, tel Telemetry)  {
	if !optOut() {
		var newEvent = Newevent(t)
		payload := map[string]interface{}{}
		payload = newEvent.Prepare(entry, tel)
		eventData := map[string]interface{}{
			"WorkstationVersion": tel.WorkstationVersion,
			"ARCH": tel.Arch,
			"HostOS": tel.HostOs,
		}
		payload["EventData"] = eventData
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
	return sessionId()
}
