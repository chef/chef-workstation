package main

// main.TelemetryEnvelope{Instance_id:"00000000-0000-0000-0000-000000000000",
// License_id:"00000000-0000-0000-0000-000000000000",
// Message_version:1, Payload_version:1, Event_type:"track", Session_id:"14638af1-95cd-4f15-9692-d9b100799631",
// Product:"chef-workstation", Product_version:"0.0.0", Install_context:"omnibus",
// Timestamp:"2018-11-02T15:03:34-04:00", Origin:"command-line",
// Payload:main.TelemetryPayload{Event:":action",
// Properties:map[string]interface {}{
//   ":installation_id":"326b0d48-b024-4285-b47b-6188bc3e162f",
//   ":run_timestamp":"2018-11-01T19:34:16Z",
//   ":host_platform":"linux",
//   ":event_data":map[interface {}]interface {}{
//     ":action":"GenerateCookbookFromResource",
//     ":target":map[interface {}]interface {}{
//       ":platform":map[interface {}]interface {}{},
//       ":hostname_sha1":interface {}(nil),
//       ":transport_type":interface {}(nil)},
//       ":duration":0.0003254690091125667}}}}

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"os"
	"os/user"
	"time"

	"github.com/gofrs/uuid"
	"github.com/radovskyb/watcher"
	"github.com/sirupsen/logrus"
	"github.com/spf13/viper"
	yaml "gopkg.in/yaml.v2"
)

// TODO this one doesn't need to be public
type TelemetrySender struct {
	endpoint_url string
	log          *logrus.Logger
	config       *viper.Viper
}

// NOTE: these structs are public in order to behave with marshal/unmarshal.
type PayloadInput struct {
	Version string
	Entries []TelemetryPayload
}

// - event: run
//   properties:
//     installation_id: 326b0d48-b024-4285-b47b-6188bc3e162f
//     run_timestamp: '2018-11-02T21:11:47Z'
//     host_platform: linux
//     event_data:
//       arguments:
//       - :redacted
//       duration: 13.99565049802186
// - event: action
//   properties:
//     installation_id: 326b0d48-b024-4285-b47b-6188bc3e162f
//     run_timestamp: '2018-11-02T21:11:47Z'
//     host_platform: linux
//     event_data:
//       action: ConvergeTarget
//       target:
//         platform:
//           name: linux
//           version: '14.04'
//           architecture: x86_64
//         hostname_sha1: 28d6ba9011aaec66788b426505afe09b32cfe169
//         transport_type: ssh
//       duration: 8.67385252402164

type TelemetryPayload struct {
	Event      string `yaml:"event"`
	Properties struct {
		Installation_id string `yaml:"installation_id" json:"installation_id",omitifempty`
		Run_timestamp   string `yaml:"run_timestamp" json:"run_timestamp"`
		Host_platform   string `yaml:"host_platform" json:"host_platform"`
		Event_data      struct {
			Action   string  `yaml:"action" json:"action"`
			Duration float64 `yaml:"duration" json:"duration"`
			Target   struct {
				Platform       map[string]interface{} `yaml:"platform" json:"platform"`
				Hostname_sha1  string                 `yaml:"hostname_sha1" json:"hostname_sha1"`
				Transport_type string                 `yaml:"transport_type" json:"transport_type"`
			} `yaml:"target" json:"target"`
		} `yaml:"event_data" json:"event_data"`
	} `yaml:"properties"`
}

type TelemetryEnvelope struct {
	Instance_id     string           `json:"instance_id"`
	License_id      string           `json:"license_id"`
	Message_version int              `json:"message_version"`
	Payload_version int              `json:"payload_version"`
	Event_type      string           `json:"type"`
	Session_id      string           `json:"session_id"`
	Product         string           `json:"product"`
	Product_version string           `json:"product_version"`
	Install_context string           `json:"install_context"`
	Timestamp       string           `json:"timestamp"`
	Origin          string           `json:"origin"`
	Payload         TelemetryPayload `json:"payload"`
}

func StartTelemetrySender(log *logrus.Logger, config *viper.Viper) {
	var url string
	if config.GetBool("telemetry.dev") {
		url = os.Getenv("CHEF_TELEMETRY_ENDPOINT")
		if url == "" {
			url = "https://telemetry-acceptance.chef.io/events"
		}
	} else {
		url = "https://telemetry.chef.io/events"
	}

	sender := TelemetrySender{log: log, config: config, endpoint_url: url}
	go sender.Start()
}

func (s *TelemetrySender) Start() {
	// TODO - this is a super-simple implementation that just looks for
	// payload files to show up and sends them.
	s.watchForChanges()

	// A better option will be to periodically
	// scan the data dir for payload files older than X, since we don't want to
	// ship them the moment they show up:

	// pollTicker := time.NewTicker(600 * time.Second)
	// defer pollTicker.Stop()
	// payloads, err := s.scanForPayloadFiles
	// for _, payload_file in payloads
	//   s.processPayloadFile(payload_file)

}

func (s *TelemetrySender) watchForChanges() {
	w := watcher.New()
	w.FilterOps(watcher.Create)

	// TODO - this runs in the context of a single user.
	//        to support multi-user, we'll want components
	//        sending directly to the One Instance of CWSD.
	usr, err := user.Current()
	if err != nil {
		s.log.Error(err)
		return
	}

	err = w.AddRecursive(fmt.Sprintf("%s/.chef-workstation/telemetry", usr.HomeDir))
	if err != nil {
		s.log.Error(err)
	}
	go func() {
		for {
			select {
			case event := <-w.Event:
				s.processFile(event.Path)
			case err := <-w.Error:
				s.log.Error(err)
			case <-w.Closed:
				return
			}
		}
	}()

	// Start the watching process
	// reports on new files every 10 minutes.
	// TODO - revert to 10 minute time
	if err := w.Start(time.Second * 1); err != nil {
		s.log.Fatal(err)
	}
}

func (s *TelemetrySender) processFile(path string) {
	s.log.Infof("Processing %s", path)
	raw, err := ioutil.ReadFile(path)
	if err != nil {
		s.log.Errorf("Could not load file %s", path)
		return
	}

	m := make(map[interface{}]interface{})
	err = yaml.Unmarshal([]byte(raw), &m)
	if err != nil {
		log.Fatalf("error: %v", err)
	}
	fmt.Printf("--- m:\n%v\n\n", m)

	payloads := PayloadInput{}
	err = yaml.Unmarshal([]byte(raw), &payloads)
	if err != nil {
		s.log.Errorf("error parsing yaml from %s: %v", path, err)
		return
	}

	s.log.Infof("Got: %v", payloads)
	// If a single file contains multiple entries, they all belong
	// to the same session - so we'll create the single session id first
	// and use it for all:
	session_id, err := uuid.NewV4()
	if err != nil {
		s.log.Errorf("Error getting UUID: %v", err)
		return
	}
	for idx, payload := range payloads.Entries {
		envelope, err := s.wrapPayload(payload, session_id)

		s.log.Infof("Payload %d: %#v", idx, envelope)
		body, err := json.MarshalIndent(envelope, "", "  ")
		s.log.Infof("Processed record %d: \n%s", idx, body)
		//s.log.Infof("Payload %d: %v", idx, raw)
		if err != nil {
			s.log.Error(err)
			continue
		}

		// fmt.Printf("Envelope: %v\n", envelope)
		resp, err := http.Post(s.endpoint_url, "application/json", bytes.NewBuffer(raw))
		if err != nil {
			s.log.Errorf("Error posting to %s: %v", s.endpoint_url, err)
			continue
		}
		var result map[string]interface{}

		json.NewDecoder(resp.Body).Decode(&result)

		if result["message"] != "" {
		  s.log.Error("Error response: ", result["message")
		}
	}

}

func (s *TelemetrySender) wrapPayload(payload TelemetryPayload, session_id uuid.UUID) (TelemetryEnvelope, error) {

	// NOTE: the idea of 'session' for chef-wrokstation seems to map
	//       1:1 to a single use of tool - so we're generating
	//       a new session for each capture instead of basing them on proximity of
	//       file times.
	return TelemetryEnvelope{
		// TODO - we should use installation ID for instance_id, instead of including it
		// as `installation_id` in event properties. That logic shoudl move out of
		// the producer who only knows about `properties`.
		Instance_id:     "00000000-0000-0000-0000-000000000000",
		Message_version: 1,
		Payload_version: 1,
		Event_type:      "track",
		Session_id:      session_id.String(),
		License_id:      "00000000-0000-0000-0000-000000000000",
		Origin:          "command-line",
		Product:         "chef-workstation",
		Product_version: "0.0.0", // TODO get this
		Install_context: "omnibus",
		Timestamp:       time.Now().Format(time.RFC3339), // TODO - time of event, not time of send
		Payload:         payload,
	}, nil

}

// Payload Sample:

// {
//   "instance_id": "00000000-0000-0000-0000-000000000000",
//   "message_version": 1,
//   "payload_version": 1,
//   "license_id": "00000000-0000-0000-0000-000000000000",
//   "type": "track",
//   "session_id": "6e6983b0-d168-478b-81d8-8836f4ec0adf",
//   "origin": "command-line",
//   "product": "chef-workstation",
//   "product_version": "0.1.114",
//   "install_context": "omnibus",
//   "timestamp": "2018-05-22T15:13:10Z",
//   "payload": {
//     "event": "error",
//     "properties": {
//
//       "installation_id": "00000000-0000-0000-0000-000000000000",
//       "component": "chef-run", # new
//       "run_timestamp": "2018-05-22T15:08:34Z",
//       "host_platform": "darwin17",
//       "event_data": {
//         "exception": {
//           "id": "Train::ClientError",
//           "message": "Your SSH Agent has no keys added, and you have not specified a password or a key file"
//         },
//	 			"duration": 0.0
//       },
//     }
//   }
// }
// The submit:
//
// TELEMETRY_ENDPOINT = "https://telemetry.chef.io".freeze
// TODO - can we pick up system settings for
//   http.post("/events", json: event).flush

// The envelope:
// class Telemetry
//   class Event
//
//     SKELETON = {
//       instance_id: "00000000-0000-0000-0000-000000000000",
//       message_version: 1.0,
//       payload_version: 1.0,
//       license_id: "00000000-0000-0000-0000-000000000000",
//       type:  "track",
//     }.freeze
//
//     attr_reader :session, :product, :origin,
//       :product_version, :install_context
//     def initialize(product, session, origin = "command-line",
//                    install_context = "omnibus", product_version = "0.0.0")
//       @product = product
//       @session = session
//       @origin = origin
//       @product_version = product_version
//       @install_context = install_context
//     end
//
//     def prepare(event)
//       time = timestamp
//       event[:properties][:timestamp] = time
//       body = SKELETON.dup
//       body.tap do |b|
//         b[:session_id] = session.id
//         b[:origin] = origin
//         b[:product] = product
//         b[:product_version] = product_version
//         b[:install_context] = install_context
//         b[:timestamp] = time
//         b[:payload] = event
//       end
//     end
//
//     def timestamp
//       Time.now.utc.strftime("%FT%TZ")
//     end
//   end
