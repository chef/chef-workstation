package cmd

import (
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

func NewPushArchiveCmd(s []string) *cobra.Command {
	return &cobra.Command{
		Use:   "push-archive POLICY_GROUP ARCHIVE_FILE",
		Short: "Push a policy archive to a policy group on the %s",
		Long: `
Publish a policy archive to a %s.

Policy archives can be created with '%s export -a'. The policy will be
applied to the given POLICY_GROUP, which is a set of nodes that share the
same run_list and cookbooks.

See the Policyfile documentation for more information:

https://docs.chef.io/policyfile/
	 `,
		RunE: func(cmd *cobra.Command, args []string) error {
			return passThroughCommand(dist.WorkstationExec, "", s)
		},
	}
}

func Test_PushArchiveCommand(t *testing.T) {
	s := []string{"diff"}
	cmd := NewPushArchiveCmd(s)
	out := cmd.Execute()
	if out.Error() != `exit status 1` {
		t.Fatalf("expected \"%s\" got \"%s\"", `exit status 1`, out.Error())
	}
}

// func Test_InstallCookbookCommand(t *testing.T) {
// 	s := []string{"install", "/Users/ngupta/Documents/projects/chef-workstation/chef-workstation/components/main-chef-wrapper/test100/Policyfile.rb"}
// 	cmd := NewInstallCmd(s)s
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
