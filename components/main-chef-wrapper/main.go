/*
Copyright © 2020 Chef Software, Inc

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
// command to run unit --  go test -tags=unit ./cmd -v  -count=1 --cover
// command to run integration --  go test -tags=integration ./integration -v  -count=1 --cover

package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"os/exec"
	"path"
	"path/filepath"
	"runtime"

	platform_lib "github.com/chef/chef-workstation/components/main-chef-wrapper/platform-lib"

	licensing "github.com/chef/go-libs/licensing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/cmd"
	homedir "github.com/mitchellh/go-homedir"
)

func doStartupTasks() error {
	createDotChef()
	platform_lib.GlobalReadFile()
	if runtime.GOOS == "windows" {
		createRubyEnvWindows()
	} else {
		createRubyEnvUnix()
	}
	return nil
}

// Attempts to create the ~/.chef directory.
// Does not report an error if this fails, because it is non-fatal:
// operations can continue if we don't create .chef, but the user might
// see some warnings from specific tools that want it.
func createDotChef() {
	path, err := homedir.Expand("~/.chef")
	if err != nil {
		return
	}
	os.Mkdir(path, 0700)
}

func createRubyEnvUnix() {
	InstallerDir := "/opt/chef-workstation"
	home, err := os.UserHomeDir()
	installationPath := path.Join(home, ".chef/ruby-env.json")
	result, err := exists(installationPath)
	if err != nil {
		log.Fatalf(err.Error())
	}
	if result != true {
		if createEnvJsonUnix(InstallerDir, installationPath) {
			return
		}
	}
	if result == true && platform_lib.MatchVersions() != true {
		if createEnvJsonUnix(InstallerDir, installationPath) {
			return
		}
	}
	platform_lib.InitializeRubyMap()
}

func createRubyEnvWindows() {
	InstallerDir := `C:\opscode\chef-workstation`
	home, err := os.UserHomeDir()
	installationPath := path.Join(home, `.chef\ruby-env.json`)
	result, err := exists(installationPath)
	if err != nil {
		log.Fatalf(err.Error())
	}
	if platform_lib.OmnibusInstall() {
		if result != true {
			if createEnvJsonWindows(InstallerDir, installationPath) {
				return
			}
		}
		if result == true && platform_lib.MatchVersions() != true {
			if createEnvJsonWindows(InstallerDir, installationPath) {
				return
			}
		}
	} else {
		if result != true {
			if createEnvJsonWindows(InstallerDir, installationPath) {
				return
			}
		}
		if result && platform_lib.MatchVersions() {
			if createEnvJsonWindows(InstallerDir, installationPath) {
				return
			}
		}
	}
	platform_lib.InitializeRubyMap()
}

func createEnvJsonUnix(InstallerDir string, installationPath string) bool {
	arg0 := fmt.Sprintf("%s/embedded/bin/ruby", InstallerDir)
	arg1 := fmt.Sprintf("%s/bin/ruby-env-script.rb", InstallerDir)
	argList := []string{arg1, installationPath}
	cmd := exec.Command(arg0, argList...)
	stdout, err := cmd.Output()

	if err != nil {
		fmt.Println(err.Error())
		return true
	}
	// Print the output
	fmt.Println(string(stdout))
	return false
}

func createEnvJsonWindows(InstallerDir string, installationPath string) bool {
	arg0 := fmt.Sprintf(`%s\embedded\bin\ruby`, InstallerDir)
	arg1 := fmt.Sprintf(`%s\bin\ruby-env-script.rb`, InstallerDir)
	argList := []string{arg1, installationPath}
	cmd := exec.Command(arg0, argList...)
	stdout, err := cmd.Output()

	if err != nil {
		fmt.Println(err.Error())
		return true
	}
	// Print the output
	fmt.Println(string(stdout))
	return false
}

func exists(path string) (bool, error) {
	_, err := os.Stat(path)
	if err == nil {
		return true, nil
	}
	if os.IsNotExist(err) {
		return false, nil
	}
	return false, err
}

func checkLicenseFlag() {
	home, _ := os.UserHomeDir()
	if len(os.Args) > 3 && os.Args[1] == "license" && os.Args[2] == "enable" && os.Args[3] == "true" {
		f, err := os.Create(filepath.Join(home, ".chef/fbffb2ea48910514676e1b7a51c7248290ea958c"))
		if err != nil {
			fmt.Println("Not able to enable chef")
			os.Exit(1)
		}
		defer f.Close()
		f.Write([]byte(`true`))
		fmt.Println("Now you can use chef commands.")
		os.Exit(1)
	} else if len(os.Args) > 3 && os.Args[1] == "license" && os.Args[2] == "enable" && os.Args[3] == "false" {
		err := os.Remove(filepath.Join(home, ".chef/fbffb2ea48910514676e1b7a51c7248290ea958c"))
		if err != nil {
			fmt.Println("Not able to disable chef")
			os.Exit(1)
		}
		fmt.Println("License feature got disabled")
		os.Exit(0)
	} else if len(os.Args) > 2 && os.Args[1] == "license" {
		info, _ := os.Stat(filepath.Join(home, ".chef/fbffb2ea48910514676e1b7a51c7248290ea958c"))
		if info == nil {
			fmt.Println("To use chef license feature you need to enable the license flag. \nTo enable it run `chef license enable true`")
			os.Exit(1)
		}
	}

}

type Configuration struct {
	ChefProductName    string `json:"chefProductName"`
	ChefEntitlementID  string `json:"chefEntitlementId"`
	ChefExecutableName string `json:"chefExecutableName"`
	LicenseServerURL   string `json:"licenseServerURL"`
}

func readLicenseConfig() Configuration {
	confFile, err := os.Open("dist/licensingConfig.json")
	if err != nil {
		panic(err)
	}
	defer confFile.Close()
	conf, err := ioutil.ReadAll(confFile)
	if err != nil {
		panic(err)
	}
	myConf := Configuration{}
	err = json.Unmarshal(conf, &myConf)
	if err != nil {
		panic(err)
	}
	return myConf
}

func featureEnabled() bool {
	home, _ := os.UserHomeDir()
	licensePath := filepath.Join(home, ".chef/fbffb2ea48910514676e1b7a51c7248290ea958c")
	info, _ := os.Stat(licensePath)
	if info != nil {
		return true
	} else {
		return false
	}
}

func main() {
	if len(os.Args) > 1 {

		if os.Args[1] == "version" || os.Args[1] == "-v" || os.Args[1] == "--version" {
			os.Args[1] = "version"
		}
	}

	doStartupTasks()
	if len(os.Args) == 1 || os.Args[1] == "version" || os.Args[1] == "help" || os.Args[1] == "-h" || os.Args[1] == "--help" {
		cmd.Execute()
		os.Exit(0)
	}
	checkLicenseFlag()
	if featureEnabled() {
		if os.Args[1] == "license" {
			cmd.Execute()
			os.Exit(0)
		}
		fmt.Println("inside license check")
		licenseConfig := readLicenseConfig()
		fmt.Println("licenseConfig", licenseConfig)
		licensing.CheckSoftwareEntitlement(licenseConfig.ChefEntitlementID, licenseConfig.LicenseServerURL)
	}
	cmd.Execute()
}
