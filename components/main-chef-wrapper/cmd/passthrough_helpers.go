package cmd

import (
	"os"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

func passThroughAnalyzeCommand(_ *cobra.Command, _ []string) error {
	return Runner.PassThroughCommand(dist.AnalyzeExec, "", os.Args[1:])
}

func passThroughWorkstationCommand(_ *cobra.Command, _ []string) error {
	return Runner.PassThroughCommand(dist.WorkstationExec, "", os.Args[1:])
}