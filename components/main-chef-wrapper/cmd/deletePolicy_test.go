package cmd

import (
	"bytes"
	"io/ioutil"
	"log"
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

func NewDeletePolicyCmd(s []string) *cobra.Command {
	return &cobra.Command{
		Use:   "delete-policy POLICY_NAME",
		Short: "Delete all revisions of POLICY_NAME policy on the %s",
		Long: `
Delete all revisions of the policy POLICY_NAME on the configured
%s. All policy revisions will be backed up locally, allowing you to
undo this operation via the '%s undelete' command.
`,
		RunE: func(cmd *cobra.Command, args []string) error {
			return passThroughCommand(dist.WorkstationExec, "", s)
		},
	}
}

func Test_DeletePolicyCommand(t *testing.T) {
	s := []string{"delete-policy"}
	cmd := NewDeletePolicyCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

func Test_DeletePolicyNameCommand(t *testing.T) {
	s := []string{"delete-policy", "POLICY_NAME"}
	cmd := NewDeletePolicyCmd(s)
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
