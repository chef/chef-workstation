package cmd

import (
	"log"
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
)

func TestCleanPolicyCookbookCommand(t *testing.T) {
	for _, test := range []struct {
		Args []string
	}{
		{
			Args: []string{"clean-policy-cookbooks", "--help"},
		},
		{
			Args: []string{"clean-policy-cookbooks"},
		},
	} {
		t.Run("", func(t *testing.T) {
			err := Runner.PassThroughCommand(dist.WorkstationExec, "", test.Args)
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully")
			}
		})
	}
}
