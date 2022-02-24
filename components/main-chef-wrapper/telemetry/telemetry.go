package telemetry

import (
	"runtime"

	platform_lib "github.com/chef/chef-workstation/components/main-chef-wrapper/platform-lib"
	"github.com/chef/go-libs/telemetry"
)

func NewTelemetry() (t telemetry.Telemetry) {

	t.Host_os = runtime.GOOS
	t.Arch = runtime.GOARCH
	t.Version = platform_lib.ComponentVersion("build_version")
	t.Payload_dir = telemetryPath()
	t.Session_file = telemetrySessionFile()
	t.Installation_identifier_file = telemetryInstallationIdentifierFile()
	t.Enabled = true
	t.Dev_mode = false
	return t

}
