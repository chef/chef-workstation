package telemetry

import (
	"log"
	"os"
	"path"
	"path/filepath"
)

const OPT_OUT_FILE = "telemetry_opt_out"
const OPT_IN_FILE = "telemetry_opt_in"

func optOut() bool {
	// We check that the user has made a decision so that we can have a default setting for robots
	return userOptedOut() || envOptOut() || localOptOut() || made()
}

func made() bool {
	return userOptedIn() || userOptedOut()
}

func userOptedOut() bool {
	file := path.Join(GetDefaultDir(), OPT_OUT_FILE)
	return fileInfo(file)
}

func userOptedIn() bool {
	file := path.Join(GetDefaultDir(), OPT_IN_FILE)
	return fileInfo(file)
}

func envOptOut() bool {
	_, ok := os.LookupEnv("CHEF_TELEMETRY_OPT_OUT")
	if !ok {
		return false
	} else {
		return true
	}
}

func localOptOut() bool {
	// found := false
	// fullPath := strings.Split(workingDirectory(), "/")
	// for i := len(fullPath) - 1; i >= 0; i-- {
	// 	candidate := filepath.Join(fullPath[0:i], ".chef", OPT_OUT_FILE)
	// 	_, err := os.Stat(candidate)
	// 	if err == nil {
	// 		found = true
	// 	}
	// }
	// return found
	return false

}

// func workingDirectory() string {

// 	if runtime.GOOS == "windows" {
// 		return os.Getenv("CD")
// 	} else {
// 		return os.Getenv("PWD")
// 	}
// }

func fileInfo(file string) bool {
	_, err := os.Stat(file)
	if err == nil {
		return true
	}
	return false
}

func GetDefaultDir() string {
	dirname, err := os.UserHomeDir()
	if err != nil {
		log.Print(err)
	}
	return filepath.Join(dirname, ".chef")
}
