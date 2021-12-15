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
	"fmt"
	"log"
	"os"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/cmd"
	homedir "github.com/mitchellh/go-homedir"
	platform_lib "github.com/chef/chef-workstation/components/main-chef-wrapper/platform-lib"

)

func doStartupTasks() error {
	createRubyEnv()
	createDotChef()
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

func createRubyEnv(){
//	get installation path
//	homepath, err := homedir.Dir()
//	if err != nil {
//		log.Fatalf(err.Error())
//	}
//	todo ==> incase home directory is needed we can add it to string
	installationPath :=  platform_lib.ExpectedOmnibusRoot() + "/ruby-env.json"
	fmt.Printf(installationPath)
	result, err := exists(installationPath)
	if err != nil {
		log.Fatalf(err.Error())
	}
	if result == true {
		fmt.Print("file exists======== ruby script not needed")
	} else {
		fmt.Print("file  does not exists============ call ruby script to make ruby-env.json file\n")
	//	 call ruby script #{install_dir}/embedded/bin/bundle/ exec ruby ruby_env_script.rb
	}
}

func exists(path string) (bool, error) {
	_, err := os.Stat(path)
	if err == nil { return true, nil }
	if os.IsNotExist(err) { return false, nil }
	return false, err
}

func main() {
	if len(os.Args) > 1 {

		if os.Args[1] == "version" || os.Args[1] == "-v" || os.Args[1] == "--version" {
			os.Args[1] = "version"
		}
	}

	doStartupTasks()
	cmd.Execute()
}
