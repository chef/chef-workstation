package core

import (
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
)

const configPath = ".chef"
const configFileName = "config.rb"

// Config this will contain all configuration required by chef (knife) command like chef infra server url,
// Chef zero host url and port
// Chef Infra Server client key
// format etc ...
type Config struct {
	ServerUrl       string `json:"server_url" yaml:"server_url"`
	ClientKey       string `json:"client_key" yaml:"client_key"`
	ConfigFile      string `json:"config_file" yaml:"config_file"`
	DefaultValue    bool   `json:"default_value" yaml:"default_value"`
	Format          string `json:"format" yaml:"format"`
	SuperMarketSite string `json:"super_market_site" yaml:"super_market_site"`
	Version         string `json:"version" yaml:"version"`
	Yes             bool   `json:"yes" yaml:"yes"`
	WithUri         string `json:"with_uri" yaml:"with_uri"`
}

// LoadConfig will load default config from client.rb at default path or in current dir
func (c *Config) LoadConfig(fileName string) (string, string) {
	configFilePath := GetConfigPath(fileName)
	configFile := filepath.Join(configFilePath, configFileName)
	file, err := ioutil.ReadFile(configFile)
	if err != nil {
		fmt.Println("WARNING: No knife configuration file found. See https://docs.chef.io/config_rb/ for details.")
		fmt.Println("WARN: Failed to read the private key /etc/chef/client.pem: #<Errno::ENOENT: No such file or directory @ rb_sysopen - /etc/chef/client.pem>")
		fmt.Println("\033[31m", "ERROR:", "\033[0m", "Your private key could not be loaded from /etc/chef/client.pem")
		fmt.Println("Check your configuration file and ensure that your private key is readable")
		os.Exit(1)
	}
	return string(file), configFilePath
}

// GetConfigPath will return default config path from current dir
func GetConfigPath(fileName string) string {
	if len(fileName) > 0 {
		filepath, err := filepath.Abs(fileName)
		if err != nil {
			fmt.Printf("WARNING: No knife configuration file found at %s \n", fileName)
			os.Exit(1)
		}
		if !checkChefDirExists(filepath) {
			fmt.Printf("WARNING: No knife configuration file found at %s \n", fileName)
			os.Exit(1)
		}
		return filepath
	}
	ex, err := os.Getwd()
	if err != nil {
		return GetDefaultConfigPath()
	}

	return filepath.Join(ex, configPath)

}

// GetDefaultConfigPath will return default config path from /etc/chef
func GetDefaultConfigPath() string {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return filepath.Join("/etc/chef", configPath)
	}
	if !checkChefDirExists(homeDir) {
		fmt.Printf("WARNING: No knife configuration file found at %s", homeDir)
		os.Exit(1)
	}
	return filepath.Join(homeDir, configPath)

}

func checkChefDirExists(path string) bool {
	return doesDirExist(filepath.Join(path, configPath))
}
