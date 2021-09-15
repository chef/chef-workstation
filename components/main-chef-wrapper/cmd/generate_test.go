package cmd

import (

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"log"
	"testing"
)

func TestGenerateCommand(t *testing.T) {
	for _, test := range []struct {
		Args   []string
	}{
		{
			Args:   []string{"generate", "--help"},
		},
		{
			Args:   []string{"generate", "cookbook", "Cookbook_Name"},
		},
	} {
		t.Run("", func(t *testing.T) {
			err := passThroughCommand(dist.WorkstationExec, "", test.Args)
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully  : %v", err)
			}
		})
	}
}