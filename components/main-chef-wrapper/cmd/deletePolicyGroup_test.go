package cmd

import (
	"bytes"
	"io/ioutil"
	"log"
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

func NewDeletePolicyGroupCmd(s []string) *cobra.Command {
	return &cobra.Command{
		Use:   "delete-policy-group POLICY_GROUP",
		Short: "Delete a policy group on %s",
		Long: `Delete the policy group POLICY_GROUP on the configured %s.
Policy Revisions associated with the policy group are not deleted. The
state of the policy group will be backed up locally, allowing you to
undo this operation via the '%s undelete' command.

See our detailed README for more information:

https://docs.chef.io/policyfile/
`,
		RunE: func(cmd *cobra.Command, args []string) error {
			return passThroughCommand(dist.WorkstationExec, "", s)
		},
	}
}

func Test_DeletePolicyGroupCommand(t *testing.T) {
	s := []string{"delete-policy-group"}
	cmd := NewDeletePolicyGroupCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

func Test_DeletePolicyGroupNameCommand(t *testing.T) {
	s := []string{"delete-policy-group", "POLICY_GROUP"}
	cmd := NewDeletePolicyGroupCmd(s)
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
