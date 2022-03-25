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

// supermarketSearchCmd represents the supermarket search
var supermarketShowCmd = &cobra.Command{
	Use:   "show",
	Short: "Use the show argument to view information about a cookbook located at Chef Supermarket.\n\n",
	Long:  ` Use the show argument to view information about a cookbook located at Chef Supermarket.`,
	Run: func(cmd *cobra.Command, args []string) {
		var ui core.UI
		supermarket.ValidateArgsAndType(args, query, ui)
		if !supermarket.ValidateArtifact(args[0]) {
			ui.Msg("only cookbook type artifact supported as of now.")
			os.Exit(1)
		}
		version := ""
		if len(args) > 2 {
			version = args[2]
		}
		var config core.Config
		config.Format = format
		supermarket.ShowCookBook(args[1], superMarketUri, ui, config, version)
		os.Exit(1)
	},
}

func init() {
	SupermarketCmd.AddCommand(supermarketShowCmd)
	supermarketShowCmd.PersistentFlags().StringVarP(&format, "format", "f", "yaml", "Use to display result in format")

}
