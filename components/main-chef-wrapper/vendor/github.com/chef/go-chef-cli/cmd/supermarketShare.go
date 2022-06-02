/*
Copyright © 2022 Author: Nitin Sanghi <nsanghi@progress.com>

*/
package cmd

import (
	"fmt"
	"os"
	"os/exec"
	"strings"

	"github.com/chef/go-chef-cli/core"
	"github.com/chef/go-chef-cli/supermarket"
	"github.com/spf13/cobra"
)

// supermarketSearchCmd represents the supermarket search
var supermarketShareCmd = &cobra.Command{
	Use:                "share <artifact-type> <artifact-name>",
	Short:              "Use the share argument to add a cookbook to Chef Supermarket.",
	Long:               `Use the share argument to add a cookbook to Chef Supermarket. This action will require a user account and a certificate for Chef Supermarket. By default, chef will use the user name and API key that is identified in the configuration file used during the upload; otherwise these values must be specified on the command line or in an alternate configuration file.`,
	DisableFlagParsing: true,
	Run: func(cmd *cobra.Command, args []string) {
		var ui core.UI
		if len(args) < 1 {
			ui.Fatal("please provide artifact type")
		}
		if !supermarket.ValidateArtifact(args[0]) {
			ui.Msg("only cookbook  artifact type is supported as of now.")
			os.Exit(1)
		}
		var cmdArgs []string
		cmdArgs = append(cmdArgs, "supermarket")
		cmdArgs = append(cmdArgs, "share")
		cmdArgs = append(cmdArgs, args[1:]...)
		cmdOut := exec.Command("knife", cmdArgs...)
		// cmdOut.Env = os.Environ()
		// cmdOut.Stdout = os.Stdout
		cmdOut.Stderr = os.Stderr
		cmdOut.Stdin = os.Stdin
		out, err := cmdOut.Output()
		if err != nil {

			fmt.Println(err)
			os.Exit(1)

		}
		if strings.Contains(string(out), "knife") {
			msg := `Use following command to share cookbook, chef supermarket share cookbook COOKBOOKNAME `
			fmt.Println(msg)
			os.Exit(1)
		} else {
			fmt.Println(string(out))
			os.Exit(1)
		}
	},
}

func init() {
	SupermarketCmd.AddCommand(supermarketShareCmd)
}
