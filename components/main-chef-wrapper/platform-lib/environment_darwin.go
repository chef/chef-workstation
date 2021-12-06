package platform_lib


import (
	"fmt"
	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/chef/chef-workstation/components/main-chef-wrapper/lib"
	"os"
	"path/filepath"
	"strings"
)

type EnvInfo struct {
	ChefWorkstation ChefWorkstationInfo
	Ruby RubyInfo
	Path []string
}


type ChefWorkstationInfo struct {
	version string
	Home string
	InstallDirectory string
	PolicyfileConfig PolicyFileConfigInfo
}
type RubyInfo struct{
	Executable string
	version string
	RubyGems GemInfo
}

type GemInfo struct{
	RubyGemsVersion string
	RubyGemsPlatforms []string
	GemEnvironment GemEnvironmentInfo
}

type PolicyFileConfigInfo struct {
	CachePath string
	StoragePath string
}

type GemEnvironmentInfo struct{
	GemRoot string
	GemHome string
	GemPath []string
}

func RunEnvironment() error {
	return nil
}

func WorkstationInfo() ChefWorkstationInfo {
	fmt.Print("workstation info")
	if omnibusInstall() == true {
		info := ChefWorkstationInfo{Version: dist.ChefCliVersion}
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
	fmt.Print("ruby info")
	rubyinfo := RubyInfo{Executable: "/opt/chef-workstation/embedded/bin/ruby"} // Gem.ruby got us this in ruby TODO- need to see how to convert this
	rubyinfo.version = "3.0.2" // Todo- RUBY_VERSION has this value in ruby, need to see ho we cn convert this one.
	rubyinfo.RubyGems = GemInfo{RubyGemsVersion: "3.2.22", RubyGemsPlatforms: []string{"ruby", "x86_64-darwin-18" }, GemEnvironment: WsEnvironmentInfo() }
	return rubyinfo
}

func WsEnvironmentInfo() GemEnvironmentInfo {
	if  omnibusInstall() == true {
		envInfo := GemEnvironmentInfo{GemRoot: lib.OmnibusGemRoot()}
		envInfo.GemHome = lib.OmibusGemHome()
		envInfo.GemPath = lib.OmibusGemPath()
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
			gempathmap := strings.Split(str, ":")
			envInfo.GemPath = gempathmap
		}
	}
	return envInfo
}

func PathInfo()  {
	
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
