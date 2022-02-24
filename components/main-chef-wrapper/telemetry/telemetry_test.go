package telemetry

import (
	"fmt"
	"reflect"
	"testing"
)

func TestNewTelemetry(t *testing.T) {
	type Telemetry struct {
		Payload_dir                  string
		Session_file                 string
		Installation_identifier_file string
		Enabled                      bool
		Dev_mode                     bool
		Host_os                      string
		Arch                         string
		Version                      string
	}

	var newData = Telemetry{"/Users/ngupta/.chef-workstation/telemetry", "/Users/ngupta/.chef-workstation/telemetry/TELEMETRY_SESSION_ID", "/Users/ngupta/.chef-workstation/installation_id", true, false, "darwin", "amd64", "22.2.802"}
	got := NewTelemetry()
	// want := 10
	fmt.Println("got is------------", reflect.TypeOf(got))
	fmt.Println("newData is------------", reflect.TypeOf(newData))

	// if got != newData {
	// 	t.Errorf("got %q, wanted %q", got, newData)
	// }
}
