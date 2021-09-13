// +build integration

package integration

import (
	"fmt"
	"github.com/chef/chef-workstation/components/main-chef-wrapper/cmd"
	"log"
	"testing"
)

func TestStartupTask(t *testing.T) {
	cmd, err := CreateDotChef()
	fmt.Print("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<",cmd)
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

func TestMainFunction(t *testing.T) {
	cmd.Execute()
}

