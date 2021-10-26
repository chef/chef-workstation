//

package integration

import (
	//"bytes"
	//"fmt"
	"github.com/spf13/cobra"
	"github.com/chef/chef-workstation/components/main-chef-wrapper/cmd"
	"log"

	//"strings"
	"testing"
	"github.com/stretchr/testify/assert"
)


func testCobraCommand(useCmd string, shortCmd string, longCmd string, arg []string,  productName string) *cobra.Command {
	return &cobra.Command{
		Use:   useCmd,
		Short: shortCmd,
		Args:   cobra.ExactArgs(1),
		Long: longCmd,
		RunE: func(cm *cobra.Command, args []string) error {
			return cmd.Runner.PassThroughCommand(productName, "", arg[1:])
		},
	}
}


func Test_ExecuteFunction(t *testing.T) {
	rootCmd := cmd.RootCmd
	assert.Nil(t, rootCmd.Execute())
	//if err := rootCmd.Execute(); err != nil {
	//	fmt.Println(err)
	//}
}

func Test_passThroughCommand(t *testing.T){
	// we can add more commands in this struct but for testing purpose going only with 3
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
