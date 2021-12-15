package lib

import (
	"encoding/json"
	"fmt"
	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	platform_lib "github.com/chef/chef-workstation/components/main-chef-wrapper/platform-lib"
	"io/ioutil"
	"log"
	"os"
	"path"
	"path/filepath"
	"strings"
)

func init() {
	rubyenvMap = UnmarshallRubyEnv()
}

func UnmarshallRubyEnv() map[string]interface{}{
	filepath := path.Join(platform_lib.OmnibusRoot(), "ruby-env.json")
	jsonFile, err := os.Open(filepath)
	if err != nil {
		fmt.Fprintln(os.Stderr, "ERROR:", err.Error())
		os.Exit(4)
	}
	byteValue, _ := ioutil.ReadAll(jsonFile)
	var manifestHash map[string]interface{}
	json.Unmarshal([]byte(byteValue), &manifestHash)
	defer jsonFile.Close()
	return manifestHash
}

func PackageHome() string{
	var packageHomeSet =  os.Getenv("CHEF_WORKSTATION_HOME")
	var packageHome string
	if len(packageHomeSet) != 0 {
		packageHome =  packageHomeSet
	}else{
		packageHome =  DefaultPackageName()
	}

	return packageHome
}


func DefaultPackageName() string{
	// this logic can be used if other logic doesn't work.
	//if runtime.GOOS == "windows" {
	//home := os.Getenv("HOMEDRIVE") + os.Getenv("HOMEPATH")
	//if home == "" {
	//home = os.Getenv("USERPROFILE")
	//home = os.Getenv("LOCALAPPDATA")
	//}
	//return home
	//}
	//return os.Getenv("HOME")
	home, err := os.UserHomeDir()
	if err != nil {
		log.Fatal( err )
	}
	return filepath.Join(home, dist.WorkstationDir)
}

func OmnibusGemRoot() string {
	return "/opt/chef-workstation/embedded/lib/ruby/gems/3.0.0" // TODO - get this dynmically using golang
}

func RubyExecutable() string {
	return "/opt/chef-workstation/embedded/bin/ruby"
}

func RubyVersion() string {
	return  "3.0.2"
}

func RubyGemsVersion() string {
	return "3.2.22"
}

func RubyGemsPlatforms() []string {
	return []string{"ruby", "x86_64-darwin-18" }
}

func OmnibusGemHome() string {
	return "/Users/prsingh/.chefdk/gem/ruby/3.0.0" // TODO - get this dynamically using golang
}

func OmnibusGemPath() []string {
	str := "/Users/prsingh/.chefdk/gem/ruby/3.0.0:/opt/chef-workstation/embedded/lib/ruby/gems/3.0.0" // TODO - get this dynmically using golang
	split := strings.Split(str, ":")
	return split
}


func OmnibusPath() []string {
	str := "/opt/chef-workstation/bin:/Users/prsingh/.chefdk/gem/ruby/3.0.0/bin:/opt/chef-workstation/embedded/bin:/Users/prsingh/.rbenv/bin:/Users/prsingh/go/bin:/Users/prsingh/.nvm/versions/node/v15.3.0/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/go/bin:/opt/chef-workstation/gitbin" // TODO - get this dynmically using golang
	split := strings.Split(str, ":")
	return split

}
