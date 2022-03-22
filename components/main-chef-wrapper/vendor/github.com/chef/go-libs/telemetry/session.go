package telemetry

import (
	"crypto/rand"
	"errors"
	"fmt"
	"io/ioutil"
	"log"
	"os"
	"path/filepath"
	"strings"
	"time"
)

func check() string {
	if liveSession() == true {
		content, err := ioutil.ReadFile(sessionFile())

		if err != nil {
			log.Print(err)
		}
		return strings.TrimSuffix(string(content), "\n")

	} else {
		return newSession()
	}
}

func id() string {
	// FileUtils.touch(session_file)
	//     @id
	fileName := sessionFile()
	_, err := os.Stat(fileName)
	if os.IsNotExist(err) {
		file, err := os.Create("TELEMETRY_SESSION_ID")
		if err != nil {
			log.Fatal(err)
		}
		defer file.Close()
	} else {
		currentTime := time.Now().Local()
		err = os.Chtimes(fileName, currentTime, currentTime)
		if err != nil {
			fmt.Println(err)
		}
	}
	return check()
}

func liveSession() bool {
	// now := time.Now()
	// expiry := now.Add(-time.Second * 600)
	_, err := os.Stat(sessionFile())
	if os.IsNotExist(err) {
		return false
	}
	// modifiedtime := file.ModTime()
	// fmt.Println("Last modified time : ", modifiedtime)
	// fmt.Println("expiry modified time : ", expiry)
	// // file && modifiedtime > expiry
	return false
}

func sessionFile() string {
	dirname, err := os.UserHomeDir()
	if err != nil {
		log.Print(err)
	}
	return filepath.Join(dirname, ".chef", "TELEMETRY_SESSION_ID")

}

func newSession() string {
	b := make([]byte, 16)
	_, err := rand.Read(b)
	if err != nil {
		log.Print(err)
	}
	uuid := fmt.Sprintf("%x-%x-%x-%x-%x",
		b[0:4], b[4:6], b[6:8], b[8:10], b[10:])

	if _, err := os.Stat(sessionFile()); errors.Is(err, os.ErrNotExist) {
		_,err := os.Create(sessionFile())
		if err != nil {
			log.Println(err)
		}
	}
	mydata := []byte(uuid)

	ioutil.WriteFile(sessionFile(), mydata, 0644)
	return uuid

}
