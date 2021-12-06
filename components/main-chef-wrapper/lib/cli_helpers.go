package lib

import (
	"fmt"
	"log"
	"os"
	"path/filepath"
	"runtime"
	"strings"
)


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

func OmnibusGemHome() string {
	return "/Users/prsingh/.chefdk/gem/ruby/3.0.0" // TODO - get this dynmically using golang
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
