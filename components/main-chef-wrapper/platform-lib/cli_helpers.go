package platform_lib

import (
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
)

var rubyenvMap map[string]interface{}

func init() {
	rubyenvMap = UnmarshallRubyEnv()
}

func PackageHome() string {
	var packageHomeSet = os.Getenv("CHEF_WORKSTATION_HOME")
	var packageHome string
	if len(packageHomeSet) != 0 {
		packageHome = packageHomeSet
	} else {
		packageHome = DefaultPackageName()
	}
	return packageHome
}

func DefaultPackageName() string {
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
		log.Fatal(err)
	}
	return filepath.Join(home, dist.WorkstationDir)
}

func OmnibusGemRoot() string {
	gemRoot := rubyenvMap["omnibus path"].(map[string]interface{})["GEM_ROOT"]
	return gemRoot.(string)
}

func RubyExecutable() string {
	return rubyenvMap["ruby info"].(map[string]interface{})["Executable"].(string)
}

func RubyVersion() string {
	return rubyenvMap["ruby info"].(map[string]interface{})["Version"].(string)
}

func RubyGemsVersion() string {
	gemversion := rubyenvMap["ruby info"].(map[string]interface{})["RubyGems"].(map[string]interface{})["RubyGems Version"].(string)
	return gemversion
}

func RubyGemsPlatforms() []interface{} {
	ptfrm := rubyenvMap["ruby info"].(map[string]interface{})["RubyGems"].(map[string]interface{})["RubyGems Platforms"].([]interface{})
	return ptfrm
}

func OmnibusGemHome() string {
	str := rubyenvMap["omnibus path"].(map[string]interface{})["GEM_HOME"].(string)
	return str
}

func OmnibusGemPath() []string {
	str := rubyenvMap["omnibus path"].(map[string]interface{})["GEM_PATH"].(string)
	split := strings.Split(str, ":")
	return split
}

func OmnibusPath() []string {
	str := rubyenvMap["omnibus path"].(map[string]interface{})["PATH"].(string)
	split := strings.Split(str, ":")
	return split

}
