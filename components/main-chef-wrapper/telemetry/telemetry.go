package telemetry

import (
	"crypto/rand"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"runtime"
	"time"

	platform_lib "github.com/chef/chef-workstation/components/main-chef-wrapper/platform-lib"
	"github.com/chef/go-libs/telemetry"
)

func StartupTelemetry() {
	FirstRunTask()
	SetupWorkstationUserDirectories()
	// StartChefCli(true)
	t := NewTelemetry()
	var redacted = []int{}
	t.TimedRunCapture(redacted)
	t.Commit()
	t.Setup()
}

func FirstRunTask() {
	//return if Dir.exist?(WS_BASE_PATH)
	_, err := os.Stat(WS_BASE_PATH)
	if err == nil {
		return
	}
	if os.IsNotExist(err) {
		createDefaultConfig()
		setupTelemetry()
	}
}

func createDefaultConfig() {
	if err := os.MkdirAll(WS_BASE_PATH, os.ModePerm); err != nil {
		log.Fatal(err)
	}
	currentTime := time.Now().Local()
	err := os.Chtimes(defaultLocation(), currentTime, currentTime)
	if err != nil {
		fmt.Println(err)
	}

}

func setupTelemetry() {

	b := make([]byte, 16)
	_, err := rand.Read(b)
	if err != nil {
		log.Print(err)
	}
	uuid := fmt.Sprintf("%x-%x-%x-%x-%x",
		b[0:4], b[4:6], b[6:8], b[8:10], b[10:])

	if _, err := os.Stat(telemetryInstallationIdentifierFile()); errors.Is(err, os.ErrNotExist) {
		_, err := os.Create(telemetryInstallationIdentifierFile())
		if err != nil {
			log.Println(err)
		}
	}
	myData := []byte(uuid)

	ioutil.WriteFile(telemetryInstallationIdentifierFile(), myData, 0644)

}

func SetupWorkstationUserDirectories() {
	fmt.Println("inside SetupWorkstationUserDirectories")
	//FileUtils.mkdir_p(Config::WS_BASE_PATH)
	//FileUtils.mkdir_p(Config.base_log_directory)
	//FileUtils.mkdir_p(Config.telemetry_path)
	os.MkdirAll(WS_BASE_PATH, os.ModePerm)
	os.MkdirAll(telemetryPath(), os.ModePerm)

}

// func StartChefCli(enforce_license bool) {
// 	fmt.Println("inside ")
// 	fmt.Println(enforce_license)
// }

func NewTelemetry() (t telemetry.Telemetry) {

	t.HostOs = runtime.GOOS
	t.Arch = runtime.GOARCH
	t.WorkstationVersion = platform_lib.ComponentVersion("build_version")
	t.PayloadDir = telemetryPath()
	t.SessionFile = telemetrySessionFile()
	t.InstallationIdentifierFile = telemetryInstallationIdentifierFile()
	t.Enabled = true
	t.DevMode = false
	return t

}
