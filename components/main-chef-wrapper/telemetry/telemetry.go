package telemetry

import (
	"fmt"
	"runtime"

	platform_lib "github.com/chef/chef-workstation/components/main-chef-wrapper/platform-lib"
)

type Telemetry struct {
	payload_dir                  string
	session_file                 string
	installation_identifier_file string
	enabled                      bool
	dev_mode                     bool
	host_os                      string
	arch                         string
	version                      string
}

func (t Telemetry) setup_telemetry() {

	t.host_os = runtime.GOOS
	t.arch = runtime.GOARCH
	t.version = platform_lib.ComponentVersion("build_version")
	t.payload_dir = "test"
	t.installation_identifier_file = "test3"
	t.enabled = true
	t.dev_mode = false
	fmt.Println("-------details-----")
	fmt.Println(t)
	// tel.Setup()

}
