package cmd

import (
	"log"
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
)

func TestDeletePolicyCommand(t *testing.T) {
	for _, test := range []struct {
		Args []string
	}{
		{
			Args: []string{"delete-policy", "--help"},
		},
		{
			Args: []string{"delete-policy", "POLICY_NAME"},
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
