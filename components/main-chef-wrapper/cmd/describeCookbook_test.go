package cmd

import (
	"bytes"
	"io/ioutil"
	"log"
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

func NewDescribeCookbookCmd(s []string) *cobra.Command {
	return &cobra.Command{
		Use:   "env",
		Short: "Prints environment variables used by %s",
		RunE: func(cmd *cobra.Command, args []string) error {
			return PassThroughCommand(dist.WorkstationExec, "", s)
		},
	}
}

func Test_DescribeCookbookCommand(t *testing.T) {
	s := []string{"describe-cookbook"}
	cmd := NewDescribeCookbookCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

func Test_DescribeCookbookPathCommand(t *testing.T) {
	s := []string{"describe-cookbook", "/Users/ngupta/Documents/projects/chef-workstation/chef-workstation/components/main-chef-wrapper/test"}
	cmd := NewDescribeCookbookCmd(s)
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
