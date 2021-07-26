package cmd

import (
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

func NewExportCmd(s []string) *cobra.Command {
	return &cobra.Command{
		Use:   "export [ Policyfile ] DESTINATION_DIRECTORY",
		Short: "Export a policy lock as a %s code repository",
		Long: `
Create a %s Zero-compatible repository containing the
cookbooks described in a Policyfile.lock.json. The exported repository also
contains a .chef/config.rb which configures %s to apply your policy.
Once the exported repo is copied to the target machine, you can apply
the policy to any machine with:

  $ %s -z

See the Policyfile documentation for more information:

https://docs.chef.io/policyfile/
`,
		RunE: func(cmd *cobra.Command, args []string) error {
			return passThroughCommand(dist.WorkstationExec, "", s)
		},
	}
}

func Test_ExportCommand(t *testing.T) {
	s := []string{"export"}
	cmd := NewExportCmd(s)
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
