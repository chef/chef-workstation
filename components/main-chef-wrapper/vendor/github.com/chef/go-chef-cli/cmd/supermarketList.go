/*
Copyright © 2022 Author: Nitin Sanghi <nsanghi@progress.com>

*/
package cmd

import (
	"os"

	"github.com/chef/go-chef-cli/core"
	"github.com/chef/go-chef-cli/supermarket"
	"github.com/spf13/cobra"
)

var sortBy, withUri, user string

// supermarketSearchCmd represents the supermarket search
var supermarketListCmd = &cobra.Command{
	Use:   "list",
	Short: "Use the list argument to view a list of cookbooks that are currently available at Chef Supermarket.",
	Long:  `Use the list argument to view a list of cookbooks that are currently available at Chef Supermarket.`,
	Run: func(cmd *cobra.Command, args []string) {
		var ui core.UI
		if len(args) < 1 {
			ui.Fatal("please provide artifact type")
		}
		if !supermarket.ValidateArtifact(args[0]) {
			ui.Msg("only cookbook type artifact supported as of now.")
			os.Exit(1)
		}
		var config core.Config
		config.Format = format
		supermarket.ListCookBook(superMarketUri, sortBy, user, withUri, ui, config)
		os.Exit(1)
	},
}

func init() {
	SupermarketCmd.AddCommand(supermarketListCmd)
	supermarketListCmd.PersistentFlags().StringVarP(&format, "format", "f", "yaml", "Use to display result in format")
	supermarketListCmd.PersistentFlags().StringVarP(&withUri, "with-uri", "w", "", "Show corresponding URIs.")
	supermarketListCmd.PersistentFlags().StringVar(&sortBy, "sort-by", "", "Use to sort the records")
	supermarketListCmd.PersistentFlags().StringVarP(&user, "owned-by", "o", "", "Show cookbooks that are owned by the USER")

}
