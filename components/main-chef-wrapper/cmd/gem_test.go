package cmd

import (
	"bytes"
	"io/ioutil"
	"log"
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

func NewGemCmd(s []string) *cobra.Command {
	return &cobra.Command{
		Use:   "gem [ARGS]",
		Short: "Runs the 'gem' command in the context of %s's Ruby",
		RunE: func(cmd *cobra.Command, args []string) error {
			return passThroughCommand(dist.WorkstationExec, "", s)
		},
	}
}

func Test_GemCommand(t *testing.T) {
	s := []string{"gem"}
	cmd := NewGemCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

func Test_GemInstallCommand(t *testing.T) {
	s := []string{"gem", "install"}
	cmd := NewGemCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

func Test_GEMListCommand(t *testing.T) {
	s := []string{"gem", "list"}
	cmd := NewGemCmd(s)
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

func Test_GEMInstallRakeCommand(t *testing.T) {
	s := []string{"gem", "install", "rake"}
	cmd := NewGemCmd(s)
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
