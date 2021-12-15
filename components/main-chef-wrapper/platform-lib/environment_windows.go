package platform_lib

import (
	"fmt"
	"github.com/chef/chef-workstation/components/main-chef-wrapper/lib"
	"log"
	"os"
	"path/filepath"
	"strings"
)

type EnvInfo struct {
	ChefWorkstation ChefWorkstationInfo `yaml:"Chef Workstation"`
	Ruby RubyInfo `yaml:"Ruby"`
	Path []string  `yaml:"Path"`
}


type ChefWorkstationInfo struct {
	Version string `yaml:"Version"`
	Home string  `yaml:"Home"`
	InstallDirectory string  `yaml:"Install Directory"`
	PolicyfileConfig PolicyFileConfigInfo `yaml:"Policyfile Config"`
}
type RubyInfo struct{
	Executable string `yaml:"Executable"`
	Version string `yaml:"Version"`
	RubyGems GemInfo `yaml:"RubyGems"`
}

type GemInfo struct{
	RubyGemsVersion string `yaml:"RubyGems Version"`
	RubyGemsPlatforms []string `yaml:"RubyGems Platforms"`
	GemEnvironment GemEnvironmentInfo `yaml:"Gem Environment"`
}

type PolicyFileConfigInfo struct {
	CachePath string `yaml:"Cache Path"`
	StoragePath string `yaml:"Storage Path"`
}

type GemEnvironmentInfo struct{
	GemRoot string `yaml:"Gem Root"`
	GemHome string `yaml:"Gem Home"`
	GemPath []string `yaml:"Gem Path"`
}

func RunEnvironment() error {
	// call all the environment info here.
	envObj := WorkstationEnvInfo()
	ymldump, err := yaml.Marshal(envObj)
	if err != nil {
		log.Fatalf("error: %v", err)
	}
	fmt.Printf("----:\n%s\n\n", string(ymldump))

	//fmt.Println(envObj)

	// make yml dump like ruby --   ui.msg YAML.dump(info)
	return nil
}

func WorkstationInfo() ChefWorkstationInfo {
	if OmnibusInstall() == true {
		info := ChefWorkstationInfo{Version: lib.ChefCliVersion}
		info.Home = lib.PackageHome()
		info.InstallDirectory = omnibusRoot() // can be shifted to cli_helper.rb
		info.PolicyfileConfig =  PolicyFileConfigInfo{CachePath: CachePath(), StoragePath: StoragePath() }
		return info
	} else {
		info := ChefWorkstationInfo{Version: "Not running from within Workstation"}
		return info
	}
}

func CachePath() string  {
	return filepath.Join(lib.DefaultPackageName(), "cache")
}

func StoragePath() string  {
	return filepath.Join(lib.DefaultPackageName(), "cookbooks")
}

func WorkstationRubyInfo() RubyInfo {
	rubyinfo := RubyInfo{Executable: "/opt/chef-workstation/embedded/bin/ruby"} // Gem.ruby got us this in ruby TODO- need to see how to convert this
	rubyinfo.Version = "3.0.2" // Todo- RUBY_VERSION has this value in ruby, need to see ho we cn convert this one.
	rubyinfo.RubyGems = GemInfo{RubyGemsVersion: "3.2.22", RubyGemsPlatforms: []string{"ruby", "x86_64-darwin-18" }, GemEnvironment: WsEnvironmentInfo() }
	return rubyinfo
}

func WsEnvironmentInfo() GemEnvironmentInfo {
	if OmnibusInstall() == true {
		envInfo := GemEnvironmentInfo{GemRoot: lib.OmnibusGemRoot()}
		envInfo.GemHome = lib.OmnibusGemHome()
		envInfo.GemPath = lib.OmnibusGemPath()
		return envInfo
	} else {
		envInfo := GemEnvironmentInfo{}
		gemroot :=  os.Getenv("GEM_ROOT")
		if gemroot != ""{
			envInfo.GemRoot = gemroot
		}
		gemhome :=  os.Getenv("GEM_HOME")
		if gemhome != ""{
			envInfo.GemHome = gemhome
		}
		gempath :=  os.Getenv("GEM_PATH")
		if gempath != ""{
			gempathmap := strings.Split(gempath, ":")
			envInfo.GemPath = gempathmap
		}
		return envInfo
	}

}

func PathInfo()  []string {
	var pathInfo []string
	if  OmnibusInstall() == true {
		pathInfo := lib.OmnibusPath()
		return pathInfo
	} else {
		pathInfoStr :=  os.Getenv("PATH")
		if pathInfoStr != ""{
			pathInfo := strings.Split(pathInfoStr, ":")
			return pathInfo
		}
	}
	return pathInfo
}

func WorkstationEnvInfo() EnvInfo {
	InfObj := EnvInfo{ChefWorkstation: WorkstationInfo()}
	InfObj.Ruby = WorkstationRubyInfo()
	InfObj.Path = PathInfo()
	return InfObj
}


//
//
//
//func PackageHome() string {
//	return "ddd"
//}
//def package_home
//@package_home ||= begin
//package_home_set = !([nil, ""].include? ENV["CHEF_WORKSTATION_HOME"])
//if package_home_set
//ENV["CHEF_WORKSTATION_HOME"]
//else
//default_package_home
//end
//end
//end

//b, err := json.Marshal(envObj)
//if err != nil {
//fmt.Println(err)
//return nil
//}
//fmt.Println(string(b))