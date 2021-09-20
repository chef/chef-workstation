package cmd

import (
	"bytes"
	"io/ioutil"
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

func NewCleanPolicyCookbooksCmd(s []string) *cobra.Command {
	return &cobra.Command{
		Use:   "clean-policy-cookbooks",
		Short: "Delete unused Policyfile cookbooks on the %s",
		Long: `Delete unused Policyfile cookbooks.  Cookbooks are considered unused
when they are not referenced by any Policyfile revision on the %s.
This command will be most helpful when you first run "chef clean-policy-revisions"
in order to remove unreferenced Policy revisions.

See the Policyfile documentation for more information:

https://docs.chef.io/policyfile/
`,
		RunE: func(cmd *cobra.Command, args []string) error {
			return PassThroughCommand(dist.WorkstationExec, "", s)
		},
	}
}

func Test_CleanPolicyCookbooksCommand(t *testing.T) {
	s := []string{"clean-policy-cookbooks"}
	cmd := NewCleanPolicyCookbooksCmd(s)
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
