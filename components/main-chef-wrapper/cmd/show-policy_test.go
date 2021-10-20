package cmd

import (
	"log"
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/chef/chef-workstation/components/main-chef-wrapper/cmd"
)

func TestShowPolicyCommand(t *testing.T) {
	for _, test := range []struct {
		Args []string
	}{
		{
			Args: []string{"show-policy"},
		},
		{
			Args: []string{"show-policy", "--help"},
		},
		{
			Args: []string{"show-policy", "POLICY_NAME", "POLICY_GROUP"},
		},
	} {
		t.Run("", func(t *testing.T) {
			err := cmd.Runner.PassThroughCommand(dist.WorkstationExec, "", test.Args)
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully")
			}
		})
	}
}
