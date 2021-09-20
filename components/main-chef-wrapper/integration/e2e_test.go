//

package integration

import (
	"fmt"
	"github.com/spf13/cobra"
	"github.com/chef/chef-workstation/components/main-chef-wrapper/cmd"
	"log"
	"testing"
)


func RootCmd(in string) *cobra.Command {
	return &cobra.Command{
		Use:   "chef",
		Short: "integration test chef",
		SilenceErrors: true,
		RunE: func(cmd *cobra.Command, args []string) (error) {
			fmt.Fprintf(cmd.OutOrStdout(), in)
			return nil
		},
	}
}

func Test_Init(t *testing.T){
	err := cmd.FlagInit()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	} else {
		log.Printf("Command executed successfully  : %v", err)
	}
}

func Test_ExecuteFunction(t *testing.T) {
	rootCmd := RootCmd("chef")
	if err := rootCmd.Execute(); err != nil {
		fmt.Println(err)
	}
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
			err := cmd.PassThroughCommand(test.productName, "", test.Args)
			//can use assert aswell
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully  : %v", err)
			}
		})
	}
}






