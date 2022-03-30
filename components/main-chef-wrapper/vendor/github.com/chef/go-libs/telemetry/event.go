package telemetry

import (
	"time"
)

type Event struct {
	Product        string `default:"nil"`
	Session        string `default:session()`
	Origin         string `default:"command-line""`
	InstallContext string `default:"omnibus"`
	ProductVersion string `default:"0.0.0"`
}

var skeleton = map[string]interface{}{
	"instance_id":     "00000000-0000-0000-0000-000000000000",
	"message_version": "1.0",
	"payload_version": "1.0",
	"license_id":      "00000000-0000-0000-0000-000000000000",
	"type":            "track",
}

func (e Event) Prepare(event EventEntry, tel Telemetry ) (map[string]interface{}) {
	// def prepare(event)
	//     time = timestamp
	//     event[:properties][:timestamp] = time
	//     body = SKELETON.dup
	//     body.tap do |b|
	//       b[:session_id] = session.id
	//       b[:origin] = origin
	//       b[:product] = product
	//       b[:product_version] = product_version
	//       b[:install_context] = install_context
	//       b[:timestamp] = time
	//       b[:payload] = event
	//     end
	//   end

	time := time.Now()
	event.Properties.RunTimestamp = time

	//event.Properties.EventData = { "HOSTOS", "ARCH", "WorkstationVersion" }
	//event.Properties.EventData

	body := make(map[string]interface{})
	for k, v := range skeleton {
		body[k] = v
	}
	body["session"] = e.Session
	body["origin"] = e.Origin
	body["product"] = e.Product
	body["product_version"] = e.ProductVersion
	body["install_context"] = e.InstallContext
	body["timestamp"] = time
	body["payload"] = event

	return body
}
