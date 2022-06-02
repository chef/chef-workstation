/*
Copyright © 2022 Author: Nitin Sanghi <nsanghi@progress.com>

*/
package cmd

import (
	"fmt"
	"os"

	"github.com/spf13/cobra"
)

var superMarketUri, configPath string

// SupermarketCmd represents the supermarket command
var SupermarketCmd = &cobra.Command{
	Use:                   "supermarket COMMAND ARTIFACT_TYPE ARTIFACT_NAME",
	Short:                 "chef supermarket subcommand is used to interact with cookbooks that are located in on the public Supermarket",
	Long:                  `The chef supermarket subcommand is used to interact with cookbooks that are located in on the public Supermarket as well as private Chef Supermarket sites. A user account is required for any community actions that write data to the Chef Supermarket; however, the following arguments do not require a user account: download, search, install, and list.`,
	DisableFlagsInUseLine: true,
	Run: func(cmd *cobra.Command, args []string) {
		if len(args) == 0 {
			cmd.Help()
			os.Exit(0)
		} else {
			fmt.Println("chef supermarket needs an artifact (cookbook or profiles) to run")
			os.Exit(1)
		}
	},
	TraverseChildren: true,
}

func init() {
	rootCmd.AddCommand(SupermarketCmd)
	SupermarketCmd.PersistentFlags().StringVarP(&superMarketUri, "supermarket-site", "m", "https://supermarket.chef.io", "will be use as cookbook locator")
	SupermarketCmd.PersistentFlags().StringVarP(&configPath, "config", "c", "", "The configuration file to use")

}
