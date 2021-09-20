package cmd

import (
	"bytes"
	"io/ioutil"
	"log"
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
			return PassThroughCommand(dist.WorkstationExec, "", s)
		},
	}
}

func Test_GenerateCommand(t *testing.T) {
	s := []string{"generate"}
	cmd := NewGenerateCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

func Test_GenerateCookbookCommand(t *testing.T) {
	s := []string{"generate", "cookbook"}
	cmd := NewGenerateCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

func Test_GenerateCookbookNameCommand(t *testing.T) {
	s := []string{"generate", "cookbook", "cookbookName"}
	cmd := NewGenerateCmd(s)
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

func Test_GenerateRecipeCommand(t *testing.T) {
	s := []string{"generate", "recipe"}
	cmd := NewGenerateCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

func Test_GenerateRecipePathCommand(t *testing.T) {
	s := []string{"generate", "recipe", "./test12"}
	cmd := NewGenerateCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

func Test_GenerateRecipePathNameCommand(t *testing.T) {
	s := []string{"generate", "recipe", "/Users/ngupta/Documents/projects/chef-workstation/chef-workstation/components/main-chef-wrapper/test100", "name"}
	cmd := NewGenerateCmd(s)
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

func Test_GenerateAttributeCommand(t *testing.T) {
	s := []string{"generate", "attribute"}
	cmd := NewGenerateCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

func Test_GenerateTemplateCommand(t *testing.T) {
	s := []string{"generate", "template"}
	cmd := NewGenerateCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

func Test_GenerateFileCommand(t *testing.T) {
	s := []string{"generate", "file"}
	cmd := NewGenerateCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

func Test_GenerateHelpersCommand(t *testing.T) {
	s := []string{"generate", "helpers"}
	cmd := NewGenerateCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

func Test_GenerateResourceCommand(t *testing.T) {
	s := []string{"generate", "resource"}
	cmd := NewGenerateCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

func Test_GeneratePolicyCommand(t *testing.T) {
	s := []string{"generate", "policyfile"}
	cmd := NewGenerateCmd(s)
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
