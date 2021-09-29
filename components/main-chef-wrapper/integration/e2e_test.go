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
			return cmd.PassThroughCommand(productName, "", arg[1:])
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

func Test_captureCommand(t *testing.T){
	rootCmd := cmd.RootCmd
	var downloadDataBags bool
	for _, test := range []struct {
		productName string
		Use string
		Short string
		Long string
		Args        []string

	}{
		{   productName: "chef-analyze",
			Use:   "capture NODE-NAME",
			Short: "Capture a node's state into a local chef-repo",
			Args:   []string{"capture", "--help"},
			Long: `
						Captures a node's state as a local chef-repo, which can then be used to
						converge locally.
						`,

		},
		{   productName: "chef-analyze",
			Use:   "capture NODE-NAME",
			Short: "Capture a node's state into a local chef-repo",
			Args:   []string{"capture", "node-abc", "-c"},
			Long: `
						Captures a node's state as a local chef-repo, which can then be used to
						converge locally.
						`,

		},
	}{
		t.Run("", func(t *testing.T) {
			captureCmd := testCobraCommand( test.Use, test.Short, test.Long, test.Args,  test.productName)
			captureCmd.PersistentFlags().BoolVarP(
				&downloadDataBags,
				"with-data-bags",
				"D", false,
				"download all data bags as part of node capture",
			)
			cmd.AddInfraFlagsToCommand(captureCmd)
			rootCmd.AddCommand(captureCmd)
			err := rootCmd.Execute()
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully  : %v", err)
			}
		})
	}

}


func Test_cleanpoliyCookbookCommand(t *testing.T){
	rootCmd := cmd.RootCmd
	for _, test := range []struct {
		productName string
		Use string
		Short string
		Long string
		Args        []string

	}{
		{   productName: "chef-cli",
			Use:   "clean-policy-cookbooks",
			Short: "Delete unused Policyfile cookbooks on the %s",
			Args:   []string{"chef", "clean-policy-cookbooks", "-v"},
			Long:  `Delete unused Policyfile cookbooks.  Cookbooks are considered unused
			when they are not referenced by any Policyfile revision on the %s.
			This command will be most helpful when you first run "chef clean-policy-revisions"
			in order to remove unreferenced Policy revisions.
			
			See the Policyfile documentation for more information:
			
			https://docs.chef.io/policyfile/
			`,
		},
		{   productName: "chef-cli",
			Use:   "clean-policy-cookbooks",
			Short: "Delete unused Policyfile cookbooks on the %s",
			Args:   []string{"chef", "clean-policy-cookbooks", "-h"},
			Long:  `Delete unused Policyfile cookbooks.  Cookbooks are considered unused
			when they are not referenced by any Policyfile revision on the %s.
			This command will be most helpful when you first run "chef clean-policy-revisions"
			in order to remove unreferenced Policy revisions.
			
			See the Policyfile documentation for more information:
			
			https://docs.chef.io/policyfile/
			`,
		},
		{   productName: "chef-cli",
			Use:   "clean-policy-cookbooks",
			Short: "Delete unused Policyfile cookbooks on the %s",
			Args:   []string{"chef", "clean-policy-cookbooks", "-D"},
			Long:  `Delete unused Policyfile cookbooks.  Cookbooks are considered unused
			when they are not referenced by any Policyfile revision on the %s.
			This command will be most helpful when you first run "chef clean-policy-revisions"
			in order to remove unreferenced Policy revisions.
			
			See the Policyfile documentation for more information:
			
			https://docs.chef.io/policyfile/
			`,
		},
		{   productName: "chef-cli",
			Use:   "clean-policy-cookbooks",
			Short: "Delete unused Policyfile cookbooks on the %s",
			Args:   []string{"chef", "clean-policy-cookbooks"},
			Long:  `Delete unused Policyfile cookbooks.  Cookbooks are considered unused
			when they are not referenced by any Policyfile revision on the %s.
			This command will be most helpful when you first run "chef clean-policy-revisions"
			in order to remove unreferenced Policy revisions.
			
			See the Policyfile documentation for more information:
			
			https://docs.chef.io/policyfile/
			`,
		},
	}{
		t.Run("", func(t *testing.T) {
			cleanPolicyCmd := testCobraCommand( test.Use, test.Short, test.Long, test.Args,  test.productName)
			rootCmd.AddCommand(cleanPolicyCmd)
			err := rootCmd.Execute()
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully  : %v", err)
			}
		})
	}

}


func Test_cleanpoliyRevisionCommand(t *testing.T){
	rootCmd := cmd.RootCmd
	for _, test := range []struct {
		productName string
		Use string
		Short string
		Long string
		Args        []string

	}{
		{   productName: "chef-cli",
			Use:   "clean-policy-revisions",
			Short: "Delete unused policy revisions on the %s",
			Args:   []string{"chef", "clean-policy-cookbooks"},
			Long: `
'clean-policy-revisions' deletes orphaned Policyfile revisions from the
%s. Orphaned Policyfile revisions are not associated to any group, and
are therefore not in active use by any nodes.

To list orphaned Policyfile revisions before deletying them,
use '%s show-policy --orphans'.
`,
		},
		{   productName: "chef-cli",
			Use:   "clean-policy-revisions",
			Short: "Delete unused policy revisions on the %s",
			Args:   []string{"chef", "clean-policy-cookbooks", "-h"},
			Long: `
'clean-policy-revisions' deletes orphaned Policyfile revisions from the
%s. Orphaned Policyfile revisions are not associated to any group, and
are therefore not in active use by any nodes.

To list orphaned Policyfile revisions before deletying them,
use '%s show-policy --orphans'.
`,
		},
		{   productName: "chef-cli",
			Use:   "clean-policy-revisions",
			Short: "Delete unused policy revisions on the %s",
			Args:   []string{"chef", "clean-policy-cookbooks", "-v"},
			Long: `
'clean-policy-revisions' deletes orphaned Policyfile revisions from the
%s. Orphaned Policyfile revisions are not associated to any group, and
are therefore not in active use by any nodes.

To list orphaned Policyfile revisions before deletying them,
use '%s show-policy --orphans'.
`,
		},
	}{
		t.Run("", func(t *testing.T) {
			cleanPolicyRevisionsCmd := testCobraCommand( test.Use, test.Short, test.Long, test.Args,  test.productName)
			rootCmd.AddCommand(cleanPolicyRevisionsCmd)
			err := rootCmd.Execute()
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




