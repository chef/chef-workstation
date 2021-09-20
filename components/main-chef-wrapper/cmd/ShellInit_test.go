package cmd

import (
	"bytes"
	"io/ioutil"
	"log"
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

func NewShellInitCookbookCmd(s []string) *cobra.Command {
	return &cobra.Command{
		Use:   "env",
		Short: "Prints environment variables used by %s",
		RunE: func(cmd *cobra.Command, args []string) error {
			return PassThroughCommand(dist.WorkstationExec, "", s)
		},
	}
}

func Test_ShellInitCommand(t *testing.T) {
	s := []string{"shell-init"}
	cmd := NewShellInitCookbookCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

func Test_ShellInitNamePathCommand(t *testing.T) {
	s := []string{"shell-init", "zsh"}
	cmd := NewShellInitCookbookCmd(s)
	b := bytes.NewBufferString("")
	cmd.SetOut(b)
	cmd.Execute()
	// fmt.Println("x is ...", x)
	out, err := ioutil.ReadAll(b)
	if err != nil {
		t.Fatal(err)
	}
	if string(out) != `` {
		t.Fatalf("expected \"%s\" got \"%s\"", ``, string(out))
	}
}
