package platform_lib

import (
	"fmt"
	"gopkg.in/yaml.v3"
	"log"
	"os"
	"path/filepath"
	"strings"
)

type EnvInfo struct {
	ChefWorkstation ChefWorkstationInfo `yaml:"Chef Workstation"`
	Ruby            RubyInfo            `yaml:"Ruby"`
	Path            []string            `yaml:"Path"`
}

type ChefWorkstationInfo struct {
	Version          string               `yaml:"Version"`
	Home             string               `yaml:"Home"`
	InstallDirectory string               `yaml:"Install Directory"`
	PolicyfileConfig PolicyFileConfigInfo `yaml:"Policyfile Config"`
}
type RubyInfo struct {
	Executable string  `yaml:"Executable"`
	Version    string  `yaml:"Version"`
	RubyGems   GemInfo `yaml:"RubyGems"`
}

type GemInfo struct {
	RubyGemsVersion   string             `yaml:"RubyGems Version"`
	RubyGemsPlatforms []interface{}      `yaml:"RubyGems Platforms"`
	GemEnvironment    GemEnvironmentInfo `yaml:"Gem Environment"`
}

type PolicyFileConfigInfo struct {
	CachePath   string `yaml:"Cache Path"`
	StoragePath string `yaml:"Storage Path"`
}

type GemEnvironmentInfo struct {
	GemRoot string   `yaml:"Gem Root"`
	GemHome string   `yaml:"Gem Home"`
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
	return nil
}

func WorkstationInfo() ChefWorkstationInfo {
	if OmnibusInstall() {
		info := ChefWorkstationInfo{Version: CliVersion()}
		info.Home = PackageHome()
		info.InstallDirectory = omnibusRoot()
		info.PolicyfileConfig = PolicyFileConfigInfo{CachePath: CachePath(), StoragePath: StoragePath()}
		return info
	} else {
		info := ChefWorkstationInfo{Version: "Not running from within Workstation"}
		return info
	}
}

func CachePath() string {
	return filepath.Join(DefaultPackageName(), "cache")
}

func StoragePath() string {
	return filepath.Join(DefaultPackageName(), "cookbooks")
}

func WorkstationRubyInfo() RubyInfo {
	rubyinfo := RubyInfo{Executable: RubyExecutable()}
	rubyinfo.Version = RubyVersion()
	rubyinfo.RubyGems = GemInfo{RubyGemsVersion: RubyGemsVersion(), RubyGemsPlatforms: RubyGemsPlatforms(), GemEnvironment: WsEnvironmentInfo()}
	return rubyinfo
}

func WsEnvironmentInfo() GemEnvironmentInfo {
	if OmnibusInstall() == true {
		envInfo := GemEnvironmentInfo{GemRoot: OmnibusGemRoot()}
		envInfo.GemHome = OmnibusGemHome()
		envInfo.GemPath = OmnibusGemPath()
		return envInfo
	} else {
		envInfo := GemEnvironmentInfo{}
		gemroot := os.Getenv("GEM_ROOT")
		if gemroot != "" {
			envInfo.GemRoot = gemroot
		}
		gemhome := os.Getenv("GEM_HOME")
		if gemhome != "" {
			envInfo.GemHome = gemhome
		}
		gempath := os.Getenv("GEM_PATH")
		if gempath != "" {
			gempathmap := strings.Split(gempath, ";")
			envInfo.GemPath = gempathmap
		}
		return envInfo
	}

}

func PathInfo() []string {
	var pathInfo []string
	if OmnibusInstall() == true {
		pathInfo := OmnibusPath()
		return pathInfo
	} else {
		pathInfoStr := os.Getenv("PATH")
		if pathInfoStr != "" {
			pathInfo := strings.Split(pathInfoStr, ";")
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
