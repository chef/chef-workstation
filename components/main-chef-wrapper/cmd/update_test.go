package cmd

import (
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

func NewUpdateCmd(s []string) *cobra.Command {
	return &cobra.Command{
		Use:   "update [ Policyfile ] [cookbook1 [cookbook2 [...cookbookN] ] ] ",
		Short: "Updates a Policyfile.lock.json with the latest run_list and cookbooks",
		Long: `
This command reads the given Policyfile, applies any changes, resolves updated
dependencies within the constraints provided in the Policyfile, and replaces
'Policyfile.lock.json'.  The updated lockfile reflects changes to the 'run_list'
and includes any compatible dependency updates.

Individual dependent cookbooks (and their dependencies) may be updated by
passing their names after the Policyfile. The Policyfile parameter is mandatory
if you want to update individual cookbooks.

See the Policyfile documentation for more information:

https://docs.chef.io/policyfile/
	 `,
		RunE: func(cmd *cobra.Command, args []string) error {
			return passThroughCommand(dist.WorkstationExec, "", s)
		},
	}
}

func Test_UpdateCommand(t *testing.T) {
	s := []string{"update"}
	cmd := NewUpdateCmd(s)
	out := cmd.Execute()
	if out.Error() != `exit status 1` {
		t.Fatalf("expected \"%s\" got \"%s\"", `exit status 1`, out.Error())
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
