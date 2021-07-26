package cmd

import (
	"bytes"
	"io/ioutil"
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

func NewUndeleteCmd(s []string) *cobra.Command {
	return &cobra.Command{
		Use:   "undelete",
		Short: "Undo a delete command",
		Long: `
Recover a deleted policy or policy group. When run with no arguments, it lists the
available undo operations. To undo the last delete operation, use '%s undelete --last'.

CAVEATS:

* '%s undelete' doesn't detect conflicts. If a deleted item has been recreated,
  running '%s undelete' will overwrite it.
* Undo information does not include cookbooks that might be referenced by
  policies. If you have cleaned the policy cookbooks after the delete operation
  you want to reverse, '%s undelete' may not be able to fully restore the
  previous state.
* The delete commands do not store access control data, so you may have to
manually reapply any ACL customizations you have made.

See the Policyfile documentation for more information:

https://docs.chef.io/policyfile/
	 `,
		RunE: func(cmd *cobra.Command, args []string) error {
			return passThroughCommand(dist.WorkstationExec, "", s)
		},
	}
}

// func Test_UndeleteCommand(t *testing.T) {
// 	s := []string{"undelete"}
// 	cmd := NewUndeleteCmd(s)
// 	out := cmd.Execute()
// 	if out.Error() != `exit status 1` {
// 		t.Fatalf("expected \"%s\" got \"%s\"", `exit status 1`, out.Error())
// 	}
// }

func Test_UndeleteCookbookCommand(t *testing.T) {
	s := []string{"undelete"}
	cmd := NewUndeleteCmd(s)
	b := bytes.NewBufferString("")
	cmd.SetOut(b)
	cmd.Execute()
	out, err := ioutil.ReadAll(b)
	if err != nil {
		t.Fatal(err)
	}
	if string(out) != `` {
		t.Fatalf("expected \"%s\" got \"%s\"", ``, string(out))
	}
}
