package cmd

import (
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

func NewEnvCmd(s []string) *cobra.Command {
	return &cobra.Command{
		Use:   "env",
		Short: "Prints environment variables used by %s",
		RunE: func(cmd *cobra.Command, args []string) error {
			return passThroughCommand(dist.WorkstationExec, "", s)
		},
	}
}

func Test_EnvCommand(t *testing.T) {
	s := []string{"diff"}
	cmd := NewEnvCmd(s)
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
