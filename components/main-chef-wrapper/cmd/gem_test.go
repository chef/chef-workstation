package cmd

import (
	"log"
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
)

func TestGemCommand(t *testing.T) {
	for _, test := range []struct {
		Args []string
	}{
		{
			Args: []string{"gem", "--help"},
		},
		{
			Args: []string{"gem", "install"},
		},
		{
			Args: []string{"gem", "install", "rake"},
		},
		{
			Args: []string{"gem", "help", "install"},
		},
		{
			Args: []string{"gem", "list"},
		},
	} {
		t.Run("", func(t *testing.T) {
			err := Runner.passThroughCommand(dist.WorkstationExec, "", test.Args)
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully")
			}
		})
	}
}
