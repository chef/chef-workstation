package cmd

import (
	"bytes"
	"io/ioutil"
	"log"
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

func NewCaptureCmd(s []string) *cobra.Command {
	return &cobra.Command{
		Use:   "capture NODE-NAME",
		Short: "Capture a node's state into a local chef-repo",
		Long: `
Captures a node's state as a local chef-repo, which can then be used to
converge locally.
`,
		RunE: func(cmd *cobra.Command, args []string) error {
			return passThroughCommand(dist.WorkstationExec, "", s)
		},
	}
}

func Test_CaptureCommand(t *testing.T) {
	s := []string{"gem", "install"}
	cmd := NewCaptureCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

func Test_CaptureNodeCommand(t *testing.T) {
	s := []string{"capture", "node-name"}
	cmd := NewCaptureCmd(s)
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

// func Test_CaptureNodeArgsCommand(t *testing.T) {
// 	s := []string{"capture", "node-name"}
// 	cmd := NewCaptureCmd(s)
// 	b := bytes.NewBufferString("")
// 	cmd.SetOut(b)
// 	argsArray := [8]string{"-s", "-k", "-n", "-c", "-h", "-p", "-o", "-d"}
// 	for i := 0; i < len(argsArray); i++ {
// 		cmd.SetArgs([]string{argsArray[i]})
// 	}
// 	// cmd.SetArgs([]string{"-a"})
// 	cmd.Execute()
// 	out, err := ioutil.ReadAll(b)
// 	if err != nil {
// 		t.Fatal(err)
// 	}
// 	if string(out) != `` {
// 		t.Fatalf("expected \"%s\" got \"%s\"", ``, string(out))
// 	}
// }
