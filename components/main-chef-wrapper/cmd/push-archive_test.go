package cmd

import (
	"bytes"
	"io/ioutil"
	"log"
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
			return PassThroughCommand(dist.WorkstationExec, "", s)
		},
	}
}

func Test_PushArchiveCommand(t *testing.T) {
	s := []string{"push-archive"}
	cmd := NewPushArchiveCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

func Test_PushArchieveFileCommand(t *testing.T) {
	s := []string{"push-archive", "POLICY_GROUP", "ARCHIVE_FILE"}
	cmd := NewPushArchiveCmd(s)
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
