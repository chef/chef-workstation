//

package integration

import (
	"github.com/chef/chef-workstation/components/main-chef-wrapper/cmd"
	"log"
	"testing"
	"github.com/stretchr/testify/assert"
)


func Test_ExecuteFunction(t *testing.T) {
	rootCmd := cmd.RootCmd
	assert.Nil(t, rootCmd.Execute())
}

func Test_passThroughCommand(t *testing.T){
	for _, test := range []struct {
		productName string
		Args        []string
	}{
		{   productName: "chef-cli",
			Args:   []string{"generate", "--help"},
		},
		{   productName: "chef-cli",
			Args:   []string{"generate"},
		},
		{   productName: "chef-cli",
			Args:   []string{"generate", "cookbook", "Cookbook_Name"},
		},
	} {
		t.Run("", func(t *testing.T) {
			err := cmd.Runner.PassThroughCommand(test.productName, "", test.Args)
			//can use assert aswell
			//assert.NotNil(t, cmd.Runner.passThroughCommand(test.productName, "", test.Args))
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully  : %v", err)
			}
		})
	}
}
