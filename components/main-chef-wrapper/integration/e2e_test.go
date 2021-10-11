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

func Test_deletePolicyCommand(t *testing.T){
	rootCmd := cmd.RootCmd
	for _, test := range []struct {
		productName string
		Use string
		Short string
		Long string
		Args        []string

	}{
		{   productName: "chef-cli",
			Use:   "delete-policy POLICY_NAME",
			Short: "Delete all revisions of POLICY_NAME policy on the %s",
			Args:   []string{"chef", "delete-policy", "-h"},
			Long: `
				Delete all revisions of the policy POLICY_NAME on the configured
				%s. All policy revisions will be backed up locally, allowing you to
				undo this operation via the '%s undelete' command.
`,
		},
		{   productName: "chef-cli",
			Use:   "delete-policy POLICY_NAME",
			Short: "Delete all revisions of POLICY_NAME policy on the %s",
			Args:   []string{"chef", "delete-policy", "-v"},
			Long: `
				Delete all revisions of the policy POLICY_NAME on the configured
				%s. All policy revisions will be backed up locally, allowing you to
				undo this operation via the '%s undelete' command.
				`,
		},
		{   productName: "chef-cli",
			Use:   "delete-policy POLICY_NAME",
			Short: "Delete all revisions of POLICY_NAME policy on the %s",
			Args:   []string{"chef", "delete-policy", "-D"},
			Long: `
				Delete all revisions of the policy POLICY_NAME on the configured
				%s. All policy revisions will be backed up locally, allowing you to
				undo this operation via the '%s undelete' command.
				`,
		},
	}{
		t.Run("", func(t *testing.T) {
			deletePolicyCmd := testCobraCommand( test.Use, test.Short, test.Long, test.Args,  test.productName)
			rootCmd.AddCommand(deletePolicyCmd)
			err := rootCmd.Execute()
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully  : %v", err)
			}
		})
	}

}

func Test_deletePolicyGroupCommand(t *testing.T){
	rootCmd := cmd.RootCmd
	for _, test := range []struct {
		productName string
		Use string
		Short string
		Long string
		Args        []string

	}{
		{   productName: "chef-cli",
			Use:   "delete-policy-group POLICY_GROUP",
			Short: "Delete a policy group on %s",
			Args:   []string{"chef", "delete-policy", "-h"},
			Long: `Delete the policy group POLICY_GROUP on the configured %s.
			Policy Revisions associated with the policy group are not deleted. The
			state of the policy group will be backed up locally, allowing you to
			undo this operation via the '%s undelete' command.
			
			See our detailed README for more information:
			
			https://docs.chef.io/policyfile/
`,
		},
		{   productName: "chef-cli",
			Use:   "delete-policy-group POLICY_GROUP",
			Short: "Delete a policy group on %s",
			Args:   []string{"chef", "delete-policy", "-v"},
			Long: `Delete the policy group POLICY_GROUP on the configured %s.
				Policy Revisions associated with the policy group are not deleted. The
				state of the policy group will be backed up locally, allowing you to
				undo this operation via the '%s undelete' command.
				
				See our detailed README for more information:
				
				https://docs.chef.io/policyfile/
				`,
		},
		{   productName: "chef-cli",
			Use:   "delete-policy-group POLICY_GROUP",
			Short: "Delete a policy group on %s",
			Args:   []string{"chef", "delete-policy", "-D"},
			Long: `Delete the policy group POLICY_GROUP on the configured %s.
				Policy Revisions associated with the policy group are not deleted. The
				state of the policy group will be backed up locally, allowing you to
				undo this operation via the '%s undelete' command.
				
				See our detailed README for more information:
				
				https://docs.chef.io/policyfile/
				`,
		},
	}{
		t.Run("", func(t *testing.T) {
			deletePolicyGroupCmd := testCobraCommand( test.Use, test.Short, test.Long, test.Args,  test.productName)
			rootCmd.AddCommand(deletePolicyGroupCmd)
			err := rootCmd.Execute()
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully  : %v", err)
			}
		})
	}

}


func Test_describeCookbookCmd(t *testing.T){
	rootCmd := cmd.RootCmd
	for _, test := range []struct {
		productName string
		Use string
		Short string
		Long string
		Args        []string

	}{
		{   productName: "chef-cli",
			Use:   "describe-cookbook COOKBOOK_PATH",
			Args:   []string{"chef", "describe-cookbook", "-h"},
			Short: "Prints cookbook checksum information for the cookbook at COOKBOOK_PATH",
		},
		{   productName: "chef-cli",
			Use:   "describe-cookbook COOKBOOK_PATH",
			Args:   []string{"chef", "describe-cookbook", "-v"},
			Short: "Prints cookbook checksum information for the cookbook at COOKBOOK_PATH",
		},
		{   productName: "chef-cli",
			Use:   "describe-cookbook COOKBOOK_PATH",
			Args:   []string{"chef", "describe-cookbook", "integration/Cookbook_Name/"},
			Short: "Prints cookbook checksum information for the cookbook at COOKBOOK_PATH",

		},
	}{
		t.Run("", func(t *testing.T) {
			describeCookbookCmd := testCobraCommand( test.Use, test.Short, test.Long, test.Args,  test.productName)
			rootCmd.AddCommand(describeCookbookCmd)
			err := rootCmd.Execute()
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully  : %v", err)
			}
		})
	}

}

func Test_diffCmd(t *testing.T){
	// need to make sure policyfile.loc.json file is in place.
	rootCmd := cmd.RootCmd
	for _, test := range []struct {
		productName string
		Use string
		Short string
		Long string
		Args        []string

	}{
		{   productName: "chef-cli",
			Use:                   "diff [POLICYFILE] [--head | --git GIT_REF | POLICY_GROUP | POLICY_GROUP...POLICY_GROUP]",
			Args:    []string{"chef", "chef", "diff", "-h"},
			Short:                 "Generate an itemized diff of two Policyfile lock documents",
		},
		{   productName: "chef-cli",
			Use:                   "diff [POLICYFILE] [--head | --git GIT_REF | POLICY_GROUP | POLICY_GROUP...POLICY_GROUP]",
			Args:   []string{"chef",  "diff", "--git", "HEAD"},
			Short:                 "Generate an itemized diff of two Policyfile lock documents",
		},
		{   productName: "chef-cli",
			Use:                   "diff [POLICYFILE] [--head | --git GIT_REF | POLICY_GROUP | POLICY_GROUP...POLICY_GROUP]",
			Args:   []string{"chef", "diff", "--git", "master"},
			Short:                 "Generate an itemized diff of two Policyfile lock documents",
		},
	}{
		t.Run("", func(t *testing.T) {
			describeCookbookCmd := testCobraCommand( test.Use, test.Short, test.Long, test.Args,  test.productName)
			rootCmd.AddCommand(describeCookbookCmd)
			err := rootCmd.Execute()
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully  : %v", err)
			}
		})
	}

}

func Test_envCmd(t *testing.T){
	rootCmd := cmd.RootCmd
	for _, test := range []struct {
		productName string
		Use string
		Short string
		Long string
		Args        []string

	}{
		{   productName: "chef-cli",
			Use:   "env",
			Short: "Prints environment variables used by %s",
			Args:    []string{"chef", "env"},
		},
	}{
		t.Run("", func(t *testing.T) {
			envCmd := testCobraCommand( test.Use, test.Short, test.Long, test.Args,  test.productName)
			rootCmd.AddCommand(envCmd)
			err := rootCmd.Execute()
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully  : %v", err)
			}
		})
	}

}

func Test_execCmd(t *testing.T){
	rootCmd := cmd.RootCmd
	for _, test := range []struct {
		productName string
		Use string
		Short string
		Long string
		Args        []string

	}{
		{   productName: "chef-cli",
			Use:   "exec SYSTEM_COMMAND (options)",
			Short: "Runs COMMAND in the context of %s",
			Args:    []string{"chef", "exec", "-h"},
		},
		{   productName: "chef-cli",
			Use:   "exec SYSTEM_COMMAND (options)",
			Short: "Runs COMMAND in the context of %s",
			Args:    []string{"chef", "exec", "-v"},
		},
		{   productName: "chef-cli",
			Use:   "exec SYSTEM_COMMAND (options)",
			Short: "Runs COMMAND in the context of %s",
			Args:    []string{"chef", "exec", "Random command"},
		},
	}{
		t.Run("", func(t *testing.T) {
			execCmd := testCobraCommand( test.Use, test.Short, test.Long, test.Args,  test.productName)
			rootCmd.AddCommand(execCmd)
			err := rootCmd.Execute()
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully  : %v", err)
			}
		})
	}

}


func Test_exportCmd(t *testing.T){
	rootCmd := cmd.RootCmd
	var force bool
	for _, test := range []struct {
		productName string
		Use string
		Short string
		Long string
		Args        []string

	}{
		{   productName: "chef-cli",
			Use:   "export [ POLICY_FILE ] DESTINATION_DIRECTORY",
			Short: "Export a policy lock as a %s code repository",
			Args:    []string{"chef", "export", "POLICY_FILE", "DESTINATION_DIRECTORY"},
		},
		{   productName: "chef-cli",
			Use:   "exec SYSTEM_COMMAND (options)",
			Short: "Runs COMMAND in the context of %s",
			Args:   []string{"export", "POLICY_FILE", "DESTINATION_DIRECTORY", "--force"},
		},
	}{
		t.Run("", func(t *testing.T) {
			exportCmd := testCobraCommand( test.Use, test.Short, test.Long, test.Args,  test.productName)
			rootCmd.AddCommand(exportCmd)
			err := rootCmd.Execute()
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully  : %v", err)
			}
		})
	}
	exportCmd.PersistentFlags().BoolVarP(&force, "force", "f", false, "If the DESTINATION_DIRECTORY is not empty, remove its contents before exporting into it")
	exportCmd.PersistentFlags().BoolVarP(&force, "archive", "a", false, "Export as a tarball archive rather than a directory")
}


func Test_gemCmd(t *testing.T){
	rootCmd := cmd.RootCmd
	for _, test := range []struct {
		productName string
		Use string
		Short string
		Long string
		Args        []string

	}{
		{   productName: "chef-cli",
			Use:   "gem [ARGS]",
			Short: "Runs the 'gem' command in the context of %s's Ruby",
			Args:    []string{"gem", "--help"},
		},
		{   productName: "chef-cli",
			Use:   "gem [ARGS]",
			Short: "Runs the 'gem' command in the context of %s's Ruby",
			Args:   []string{"gem", "install"},
		},
		{   productName: "chef-cli",
			Use:   "gem [ARGS]",
			Short: "Runs the 'gem' command in the context of %s's Ruby",
			Args:   []string{"gem", "install", "rake"},
		},
		{   productName: "chef-cli",
			Use:   "gem [ARGS]",
			Short: "Runs the 'gem' command in the context of %s's Ruby",
			Args:   []string{"gem", "list"},
		},
	}{
		t.Run("", func(t *testing.T) {
			gemCmd := testCobraCommand( test.Use, test.Short, test.Long, test.Args,  test.productName)
			rootCmd.AddCommand(gemCmd)
			err := rootCmd.Execute()
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully  : %v", err)
			}
		})
	}
}


func Test_generateCmd(t *testing.T){
	rootCmd := cmd.RootCmd
	for _, test := range []struct {
		productName string
		Use string
		Short string
		Long string
		Args        []string

	}{
		{   productName: "chef-cli",
			Use:   "generate GENERATOR",
			Short: "Generate a new repository, cookbook, or other component",
			Args:   []string{"chef", "generate", "--help"},
		},
		{   productName: "chef-cli",
			Use:   "generate GENERATOR",
			Short: "Generate a new repository, cookbook, or other component",
			Args:   []string{"chef", "generate", "cookbook", "cookbook_name"},
		},
		{   productName: "chef-cli",
			Use:   "generate GENERATOR",
			Short: "Generate a new repository, cookbook, or other component",
			Args:   []string{"chef", "generate", "recipe", "cookbook_name", "recipe_name"},
		},
		{   productName: "chef-cli",
			Use:   "generate GENERATOR",
			Short: "Generate a new repository, cookbook, or other component",
			Args:   []string{"chef", "generate", "attribute", "cookbook_name", "attribute_name"},
		},
		{   productName: "chef-cli",
			Use:   "generate GENERATOR",
			Short: "Generate a new repository, cookbook, or other component",
			Args:   []string{"chef", "generate", "template", "cookbook_name", "template_name"},
		},
		{   productName: "chef-cli",
			Use:   "generate GENERATOR",
			Short: "Generate a new repository, cookbook, or other component",
			Args:   []string{"chef", "generate", "helpers", "cookbook_name", "helper_name"},
		},
		{   productName: "chef-cli",
			Use:   "generate GENERATOR",
			Short: "Generate a new repository, cookbook, or other component",
			Args:   []string{"chef", "generate", "helpers", "policyfile", "policy_name"},
		},
	}{
		t.Run("", func(t *testing.T) {
			generateCmd := testCobraCommand( test.Use, test.Short, test.Long, test.Args,  test.productName)
			rootCmd.AddCommand(generateCmd)
			err := rootCmd.Execute()
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully  : %v", err)
			}
		})
	}
}


func Test_installCmd(t *testing.T){
	rootCmd := cmd.RootCmd
	for _, test := range []struct {
		productName string
		Use string
		Short string
		Long string
		Args        []string

	}{
		{   productName: "chef-cli",
			Use:   "install [ POLICYFILE_PATH ]",
			Short: "Install cookbooks from a Policyfile and generate a locked cookbook set",
			Args:   []string{"chef", "install", "--help"},
		},
		{   productName: "chef-cli",
			Use:   "install [ POLICYFILE_PATH ]",
			Short: "Install cookbooks from a Policyfile and generate a locked cookbook set",
			Args:   []string{"chef", "install"},
		},
		{   productName: "chef-cli",
			Use:   "install [ POLICYFILE_PATH ]",
			Short: "Install cookbooks from a Policyfile and generate a locked cookbook set",
			Args:   []string{"chef", "install", "Policyfile.rb"},
		},
	}{
		t.Run("", func(t *testing.T) {
			installCmd := testCobraCommand( test.Use, test.Short, test.Long, test.Args,  test.productName)
			rootCmd.AddCommand(installCmd)
			err := rootCmd.Execute()
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully  : %v", err)
			}
		})
	}
}

func Test_pushCmd(t *testing.T){
	rootCmd := cmd.RootCmd
	for _, test := range []struct {
		productName string
		Use string
		Short string
		Long string
		Args        []string

	}{
		{   productName: "chef-cli",
			Use:   "push POLICY_GROUP [ POLICY_FILE ]",
			Short: "Push a local policyfile lock to a policy group on the %s",
			Args:   []string{"chef", "push"},
		},
		{   productName: "chef-cli",
			Use:   "push POLICY_GROUP [ POLICY_FILE ]",
			Short: "Push a local policyfile lock to a policy group on the %s",
			Args:   []string{"chef", "push", "--help"},
		},
		{   productName: "chef-cli",
			Use:   "push POLICY_GROUP [ POLICY_FILE ]",
			Short: "Push a local policyfile lock to a policy group on the %s",
			Args:   []string{"chef", "push", "POLICY_GROUP", "POLICY_FILE"},
		},
	}{
		t.Run("", func(t *testing.T) {
			pushCmd := testCobraCommand( test.Use, test.Short, test.Long, test.Args,  test.productName)
			rootCmd.AddCommand(pushCmd)
			err := rootCmd.Execute()
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully  : %v", err)
			}
		})
	}
}
func Test_shellInitCmd(t *testing.T){
	rootCmd := cmd.RootCmd
	for _, test := range []struct {
		productName string
		Use string
		Short string
		Long string
		Args        []string

	}{
		{   productName: "chef-cli",
			Use:   "shell-init ",
			Short: "Set shell context to the %s environment",
			Args:   []string{"chef", "shell-init", "powershell"},
		},
	}{
		t.Run("", func(t *testing.T) {
			shellInitCmd := testCobraCommand( test.Use, test.Short, test.Long, test.Args,  test.productName)
			rootCmd.AddCommand(shellInitCmd)
			err := rootCmd.Execute()
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully  : %v", err)
			}
		})
	}
}


func Test_undeleteCmd(t *testing.T){
	rootCmd := cmd.RootCmd
	for _, test := range []struct {
		productName string
		Use string
		Short string
		Long string
		Args        []string

	}{
		{   productName: "chef-cli",
			Use:   "undelete",
			Short: "Undo a delete command",
			Args:   []string{"chef", "undelete", "--help"},
		},
		{   productName: "chef-cli",
			Use:   "undelete",
			Short: "Undo a delete command",
			Args:   []string{"chef", "undelete"},
		},
	}{
		t.Run("", func(t *testing.T) {
			undeleteCmd := testCobraCommand( test.Use, test.Short, test.Long, test.Args,  test.productName)
			rootCmd.AddCommand(undeleteCmd)
			err := rootCmd.Execute()
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully  : %v", err)
			}
		})
	}
}

func Test_updateCmd(t *testing.T){
	rootCmd := cmd.RootCmd
	for _, test := range []struct {
		productName string
		Use string
		Short string
		Long string
		Args        []string

	}{
		{   productName: "chef-cli",
			Use:   "undelete",
			Short: "Undo a delete command",
			Args:   []string{"chef", "update", "--help"},
		},
		{   productName: "chef-cli",
			Use:   "undelete",
			Short: "Undo a delete command",
			Args:   []string{"chef", "update"},
		},
		{   productName: "chef-cli",
			Use:   "undelete",
			Short: "Undo a delete command",
			Args:   []string{"chef", "update", "Policyfile.rb"},
		},
	}{
		t.Run("", func(t *testing.T) {
			updateCmd := testCobraCommand( test.Use, test.Short, test.Long, test.Args,  test.productName)
			rootCmd.AddCommand(updateCmd)
			err := rootCmd.Execute()
			if err != nil {
				log.Printf("Command finished with error: %v", err)
			} else {
				log.Printf("Command executed successfully  : %v", err)
			}
		})
	}
}


// https://github.com/spf13/cobra/blob/master/command_test.go