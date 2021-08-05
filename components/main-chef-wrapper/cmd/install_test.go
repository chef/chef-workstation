package cmd

import (
	"bytes"
	"io/ioutil"
	"log"
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

func NewInstallCmd(s []string) *cobra.Command {
	return &cobra.Command{
		Use:   "install [ POLICYFILE_PATH ]",
		Short: "Install cookbooks from a Policyfile and generate a locked cookbook set",
		Long: `

Evaluate POLICYFILE_PATH to find a compatible set of cookbooks for the
policy's run_list and cache them locally.  Create or update the Policyfile.lock.json
to describe the locked cookbook set. You can use the lockfile to install the locked
cookbooks on another machine.

You can also push the lockfile to a "policy group" on a %s and
apply that exact set of cookbooks to nodes in your infrastructure.

See the Policyfile documentation for more information:

https://docs.chef.io/policyfile/
	 `,
		RunE: func(cmd *cobra.Command, args []string) error {
			return passThroughCommand(dist.WorkstationExec, "", s)
		},
	}
}

func Test_InstallCommand(t *testing.T) {
	s := []string{"install"}
	cmd := NewInstallCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

func Test_InstallCookbookCommand(t *testing.T) {
	s := []string{"install", "/Users/ngupta/Documents/projects/chef-workstation/chef-workstation/components/main-chef-wrapper/test100/Policyfile.rb"}
	cmd := NewInstallCmd(s)
	b := bytes.NewBufferString("")
	cmd.SetOut(b)
	// cmd.SetArgs([]string{"-a"})
	cmd.Execute()
	out, err := ioutil.ReadAll(b)
	if err != nil {
		t.Fatal(err)
	}
	if string(out) != `` {
		t.Fatalf("expected \"%s\" got \"%s\"", ``, string(out))
	}
}
