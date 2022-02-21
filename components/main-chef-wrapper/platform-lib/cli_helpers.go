package platform_lib

import (
	"log"
	"os"
	"path/filepath"
	"strings"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
)

var rubyenvMap map[string]interface{}

func InitializeRubyMap() {
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
	home, err := os.UserHomeDir()
	if err != nil {
		log.Fatal(err)
	}
	return filepath.Join(home, dist.WorkstationDir)
}

func OmnibusGemRoot() string {
	gemRoot := ""
	if rubyenvMap == nil {
		return gemRoot
	}
	data, ok := rubyenvMap["omnibus path"].(map[string]interface{})
	if ok {
		gemRoot = data["GEM_ROOT"].(string)
	}
	return gemRoot
}

func RubyExecutable() string {
	rubyExe := ""
	if rubyenvMap == nil {
		return rubyExe
	}
	data, ok := rubyenvMap["ruby info"].(map[string]interface{})
	if ok {
		rubyExe = data["Executable"].(string)
	}
	return rubyExe
}

func RubyVersion() string {
	rubyVersion := ""
	if rubyenvMap == nil {
		return rubyVersion
	}
	data, ok := rubyenvMap["ruby info"].(map[string]interface{})
	if ok {
		rubyVersion = data["Version"].(string)
	}
	return rubyVersion
}

func CliVersion() string {
	cliVersion := ""
	if rubyenvMap == nil {
		return cliVersion
	}
	data, ok := rubyenvMap["chef-cli"]
	if ok {
		cliVersion = data.(string)
	}
	return cliVersion
}

func RubyGemsVersion() string {
	gemversion := ""
	if rubyenvMap == nil {
		return gemversion
	}
	data, ok := rubyenvMap["ruby info"].(map[string]interface{})
	if ok {
		ndata, ok := data["RubyGems"].(map[string]interface{})
		{
			if ok {
				gemversion = ndata["RubyGems Version"].(string)
			}
		}
	}
	return gemversion
}

func RubyGemsPlatforms() []interface{} {
	if rubyenvMap == nil {
		return nil
	}
	ptfrm := rubyenvMap["ruby info"].(map[string]interface{})["RubyGems"].(map[string]interface{})["RubyGems Platforms"].([]interface{})
	return ptfrm
}

func OmnibusGemHome() string {
	str := ""
	if rubyenvMap == nil {
		return str
	}
	data, ok := rubyenvMap["omnibus path"].(map[string]interface{})
	if ok {
		str = data["GEM_HOME"].(string)
	}
	return str
}

func OmnibusGemPath() []string {
	gemPath := []string{""}
	if rubyenvMap == nil {
		return gemPath
	}
	data, ok := rubyenvMap["omnibus path"].(map[string]interface{})
	if ok {
		str := data["GEM_PATH"].(string)
		gemPath = strings.Split(str, ":")
	}
	return gemPath
}

func OmnibusPath() []string {
	if rubyenvMap == nil {
		return []string{""}
	}
	str := rubyenvMap["omnibus path"].(map[string]interface{})["PATH"].(string)
	split := strings.Split(str, ":")
	return split

}
