package cmd

import (
	"log"
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
)

func TestCleanPolicyRevisionCommand(t *testing.T) {
	for _, test := range []struct {
		Args []string
	}{
		{
			Args: []string{"clean-policy-revisions", "--help"},
		},
		{
			Args: []string{"clean-policy-revisions"},
		},
	} {
		t.Run("", func(t *testing.T) {
			err :=  Runner.PassThroughCommand(dist.WorkstationExec, "", test.Args)
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully")
			}
		})
	}
}
