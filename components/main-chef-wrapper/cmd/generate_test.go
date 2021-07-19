package cmd

import (
	"bytes"
	"io/ioutil"
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

func NewGenerateCmd(s []string) *cobra.Command {
	return &cobra.Command{
		Use:   "generate GENERATOR",
		Short: "Generate a new repository, cookbook, or other component",
		Long: `Generate a new repository, cookbook, or other component.
Available generators:
  cookbook        Generate a single cookbook
	recipe          Generate a single recipe
	attribute       Generate an attributes file
	template        Generate a file template
	file            Generate a cookbook file
	helpers         Generate a cookbook helper file in libraries/
	resource        Generate a custom resource
	repo            Generate a %s code repository
	policyfile      Generate a Policyfile for use with install/push commands
	generator       Copy %s's generator cookbook so you can customize it
	build-cookbook  Generate a build cookbook
	 `,
		RunE: func(cmd *cobra.Command, args []string) error {
			return passThroughCommand(dist.WorkstationExec, "", s)
		},
	}
}

func Test_GenerateCommand(t *testing.T) {
	s := []string{"generate"}
	cmd := NewGenerateCmd(s)
	// fmt.Println("----cmd is ---", cmd)
	// b := bytes.NewBufferString("")
	// cmd.SetOut(b)
	// cmd.SetArgs([]string{""})
	out := cmd.Execute()
	// fmt.Println("var7 = ", reflect.TypeOf(out))
	// fmt.Println("output is--------", out)
	// if out != nil {
	// 	t.Fatal(out)
	// }

	// fmt.Println("-------b is--------", b)
	// output, err := ioutil.ReadAll(b)
	// // fmt.Println("---------err-----", err)
	// // fmt.Println("var7 = ", reflect.TypeOf(string(out)))
	// fmt.Println("---------out:-----", string(out))
	// if err != nil {
	// 	t.Fatal(err)
	// }
	if out.Error() != `exit status 1` {
		t.Fatalf("expected \"%s\" got \"%s\"", `exit status 1`, out.Error())
	}
}

func Test_GenerateCookbookCommand(t *testing.T) {
	s := []string{"generate", "cookbook"}
	cmd := NewGenerateCmd(s)
	out := cmd.Execute()
	if out.Error() != `exit status 1` {
		t.Fatalf("expected \"%s\" got \"%s\"", `exit status 1`, out.Error())
	}
}

func Test_GenerateCookbookNameCommand(t *testing.T) {
	s := []string{"generate", "cookbook", "cookbookName"}
	cmd := NewGenerateCmd(s)
	b := bytes.NewBufferString("")
	cmd.SetOut(b)
	// cmd.SetArgs([]string{""})
	cmd.Execute()
	_, err := ioutil.ReadAll(b)
	if err != nil {
		t.Fatal(err)
	}
}
