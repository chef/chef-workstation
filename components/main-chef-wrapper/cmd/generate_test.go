package cmd

import (
	"log"
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
)

func TestGenerateCommand(t *testing.T) {
	for _, test := range []struct {
		Args []string
	}{
		{
			Args: []string{"generate", "--help"},
		},
		{
			Args: []string{"generate", "cookbook", "cookbook_name"},
		},
		{
			Args: []string{"generate", "recipe", "cookbook_name", "recipe_name"},
		},
		{
			Args: []string{"generate", "attribute", "cookbook_name", "attribute_name"},
		},
		{
			Args: []string{"generate", "template", "cookbook_name", "template_name"},
		},
		{
			Args: []string{"generate", "file", "cookbook_name", "file_name"},
		},
		{
			Args: []string{"generate", "helpers", "cookbook_name", "helper_name"},
		},
		{
			Args: []string{"generate", "resource", "cookbook_name", "resource_name"},
		},
		{
			Args: []string{"generate", "policyfile"},
		},
		{
			Args: []string{"generate", "policyfile", "policy_name"},
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
