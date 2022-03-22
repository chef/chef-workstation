/*
Copyright © 2022 Author: Nitin Sanghi <nsanghi@progress.com>

*/
package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

var superMarkerUri string

// SupermarketCmd represents the supermarket command
var SupermarketCmd = &cobra.Command{
	Use:   "supermarket",
	Short: "knife supermarket subcommand is used to interact with cookbooks that are located in on the public Supermarket",
	Long:  `The knife supermarket subcommand is used to interact with cookbooks that are located in on the public Supermarket as well as private Chef Supermarket sites. A user account is required for any community actions that write data to the Chef Supermarket; however, the following arguments do not require a user account: download, search, install, and list.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("supermarket need artifact type")
	},
	TraverseChildren: true,
}

func init() {
	rootCmd.AddCommand(SupermarketCmd)
	SupermarketCmd.PersistentFlags().StringVarP(&superMarkerUri, "supermarket-site", "m", "https://supermarket.chef.io", "will be use as cookbook locator")

}
