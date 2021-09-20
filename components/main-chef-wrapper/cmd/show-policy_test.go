package cmd

import (
	"log"
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

func NewShowPolicyCmd(s []string) *cobra.Command {
	return &cobra.Command{
		Use:   "show-policy [ POLICY_NAME [ POLICY_GROUP ] ]",
		Short: "Show Policyfile objects on the %s",
		Long: `
Display the revisions of Policyfiles on the %s.
By default, only active policy revisions are shown. Use the '--orphans'
option to show policy revisions that are not assigned to any policy group.

When both POLICY_NAME and POLICY_GROUP are given, the command shows the content
of the active Policyfile lock for the given POLICY_GROUP. See also the 'diff'
command.

See the Policyfile documentation for more information:

https://docs.chef.io/policyfile/
	 `,
		RunE: func(cmd *cobra.Command, args []string) error {
			return PassThroughCommand(dist.WorkstationExec, "", s)
		},
	}
}

func Test_ShowPolicyCommand(t *testing.T) {
	s := []string{"show-policy"}
	cmd := NewShowPolicyCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

// func Test_InstallCookbookCommand(t *testing.T) {
// 	s := []string{"install", "/Users/ngupta/Documents/projects/chef-workstation/chef-workstation/components/main-chef-wrapper/test100/Policyfile.rb"}
// 	cmd := NewInstallCmd(s)
// 	b := bytes.NewBufferString("")
// 	cmd.SetOut(b)
// 	cmd.Execute()
// 	out, err := ioutil.ReadAll(b)
// 	if err != nil {
// 		t.Fatal(err)
// 	}
// 	if string(out) != `` {
// 		t.Fatalf("expected \"%s\" got \"%s\"", ``, string(out))
// 	}
// }
