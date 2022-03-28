package telemetry

import (
	"fmt"
	"github.com/chef/go-libs/telemetry"
	_ "github.com/chef/go-libs/telemetry"
	"reflect"
	"testing"
)

func TestNewTelemetry(t *testing.T) {
	type Telemetry struct {
		PayloadDir                 string
		SessionFile                string
		InstallationIdentifierFile string
		Enabled                    bool
		DevMode                    bool
		HostOs                     string
		Arch                       string
		Version                    string
	}

	newData := telemetry.Telemetry{"/Users/ngupta/.chef-workstation/telemetry", "/Users/ngupta/.chef-workstation/telemetry/TELEMETRY_SESSION_ID", "/Users/ngupta/.chef-workstation/installation_id", true, false, "darwin", "amd64", "22.2.802"}
	got := NewTelemetry()

	if got != newData {
		t.Errorf("got %q, wanted %q", got, newData)
	}
}

func TestCreateDefaultConfig(t *testing.T) {
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
	Got := NewTelemetry()
	// want := 10
	fmt.Println("got is------------", reflect.TypeOf(Got))
	fmt.Println("newData is------------", reflect.TypeOf(newData))

	// if got != newData {
	// 	t.Errorf("got %q, wanted %q", got, newData)
	// }
}

func TestStartupTelemetry(t *testing.T) {

	err := FirstRunTask()
	if err != nil {
		fmt.Println(err)
	}
	err1 := SetupWorkstationUserDirectories()
	if err != nil {
		fmt.Println(err1)
	}
}
