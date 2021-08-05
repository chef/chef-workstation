package cmd

import (
	"bytes"
	"io/ioutil"
	"log"
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

func NewPushCmd(s []string) *cobra.Command {
	return &cobra.Command{
		Use:   "push POLICY_GROUP [ Policyfile ]",
		Short: "Push a local Policyfile lock to a policy group on the %s",
		Long: `
Upload an existing Policyfile.lock.json to a %s, along
with all the cookbooks contained in the Policy lock. The Policy lock is applied
to a specific POLICY_GROUP, which is a set of nodes that share the same
run_list and cookbooks.

See the Policyfile documentation for more information:

https://docs.chef.io/policyfile/
	 `,
		RunE: func(cmd *cobra.Command, args []string) error {
			return passThroughCommand(dist.WorkstationExec, "", s)
		},
	}
}

func Test_PushCommand(t *testing.T) {
	s := []string{"push"}
	cmd := NewPushCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

func Test_PushPolicyFileCommand(t *testing.T) {
	s := []string{"push", "POLICY_GROUP", "POLICY_GROUP"}
	cmd := NewPushCmd(s)
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
