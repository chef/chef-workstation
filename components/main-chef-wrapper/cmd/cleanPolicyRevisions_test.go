package cmd

import (
	"bytes"
	"io/ioutil"
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

func NewCleanPolicyRevisionsCmd(s []string) *cobra.Command {
	return &cobra.Command{
		Use:   "clean-policy-revisions",
		Short: "Delete unused policy revisions on the %s",
		Long: `
'clean-policy-revisions' deletes orphaned Policyfile revisions from the
%s. Orphaned Policyfile revisions are not associated to any group, and
are therefore not in active use by any nodes.

To list orphaned Policyfile revisions before deletying them,
use '%s show-policy --orphans'.
`,
		RunE: func(cmd *cobra.Command, args []string) error {
			return passThroughCommand(dist.WorkstationExec, "", s)
		},
	}
}

func Test_CleanPolicyRevisionsCommand(t *testing.T) {
	s := []string{"clean-policy-revisions"}
	cmd := NewCleanPolicyRevisionsCmd(s)
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
