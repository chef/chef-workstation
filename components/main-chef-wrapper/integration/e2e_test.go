//

package integration

import (
	//"bytes"
	"fmt"
	"github.com/spf13/cobra"
	"github.com/chef/chef-workstation/components/main-chef-wrapper/cmd"
	"log"
	//"strings"
	"testing"
	"github.com/stretchr/testify/assert"
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

//func Test_Init(t *testing.T){
//	err := cmd.FlagInit()
//	if err != nil {
//		log.Printf("Command finished with error: %v", err)
//	} else {
//		log.Printf("Command executed successfully  : %v", err)
//	}
//}

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
			err := cmd.PassThroughCommand(test.productName, "", test.Args)
			//can use assert aswell
			//assert.NotNil(t, cmd.PassThroughCommand(test.productName, "", test.Args))
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully  : %v", err)
			}
		})
	}
}
//reference for all the cmd command test
//func TestSingleCommand(t *testing.T) {
//	var rootCmdArgs []string
//	rootCmd := &Command{
//		Use:  "root",
//		Args: ExactArgs(2),
//		Run:  func(_ *Command, args []string) { rootCmdArgs = args },
//	}
//	aCmd := &Command{Use: "a", Args: NoArgs, Run: emptyRun}
//	bCmd := &Command{Use: "b", Args: NoArgs, Run: emptyRun}
//	rootCmd.AddCommand(aCmd, bCmd)
//
//	output, err := executeCommand(rootCmd, "one", "two")
//	if output != "" {
//		t.Errorf("Unexpected output: %v", output)
//	}
//	if err != nil {
//		t.Errorf("Unexpected error: %v", err)
//	}
//
//	got := strings.Join(rootCmdArgs, " ")
//	if got != onetwo {
//		t.Errorf("rootCmdArgs expected: %q, got: %q", onetwo, got)
//	}
//}
//
//
//func executeCommand(root *Command, args ...string) (output string, err error) {
//	_, output, err = executeCommandC(root, args...)
//	return output, err
//}
//
//func executeCommandC(root *Command, args ...string) (c *Command, output string, err error) {
//	buf := new(bytes.Buffer)
//	root.SetOut(buf)
//	root.SetErr(buf)
//	root.SetArgs(args)
//
//	c, err = root.ExecuteC()
//
//	return c, buf.String(), err
//}
//
//
//func TestChildCommand(t *testing.T) {
//	var child1CmdArgs []string
//	rootCmd := &Command{Use: "root", Args: cobra.NoArgs, Run: cobra.emptyRun}
//	child1Cmd := &Command{
//		Use:  "child1",
//		Args: ExactArgs(2),
//		Run:  func(_ *Command, args []string) { child1CmdArgs = args },
//	}
//	child2Cmd := &Command{Use: "child2", Args: cobra.NoArgs, Run: cobra.emptyRun}
//	rootCmd.AddCommand(child1Cmd, child2Cmd)
//
//	output, err := executeCommand(rootCmd, "child1", "one", "two")
//	if output != "" {
//		t.Errorf("Unexpected output: %v", output)
//	}
//	if err != nil {
//		t.Errorf("Unexpected error: %v", err)
//	}
//
//	got := strings.Join(child1CmdArgs, " ")
//	if got != onetwo {
//		t.Errorf("child1CmdArgs expected: %q, got: %q", onetwo, got)
//	}
//}
//
//func TestCallCommandWithoutSubcommands(t *testing.T) {
//	rootCmd := &Command{Use: "root", Args: NoArgs, Run: emptyRun}
//	_, err := executeCommand(rootCmd)
//	if err != nil {
//		t.Errorf("Calling command without subcommands should not have error: %v", err)
//	}
//}
//
//
//func TestRootExecuteUnknownCommand(t *testing.T) {
//	rootCmd := &Command{Use: "root", Run: emptyRun}
//	rootCmd.AddCommand(&Command{Use: "child", Run: emptyRun})
//
//	output, _ := executeCommand(rootCmd, "unknown")
//
//	expected := "Error: unknown command \"unknown\" for \"root\"\nRun 'root --help' for usage.\n"
//
//	if output != expected {
//		t.Errorf("Expected:\n %q\nGot:\n %q\n", expected, output)
//	}
//}




