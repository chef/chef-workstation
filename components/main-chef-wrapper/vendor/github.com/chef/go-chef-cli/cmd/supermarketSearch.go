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

var query, format string

// supermarketSearchCmd represents the supermarket search
var supermarketSearchCmd = &cobra.Command{
	Use:   "search",
	Short: "Search indexes allow queries to be made for any type of data that is indexed by the Chef Infra Server, including data bags (and data bag items), environments, nodes, and roles",
	Long:  `Search indexes allow queries to be made for any type of data that is indexed by the Chef Infra Server, including data bags (and data bag items), environments, nodes, and roles. A defined query syntax is used to support search patterns like exact, wildcard, range, and fuzzy. A search is a full-text query that can be done from several locations, including from within a recipe, by using the search subcommand in knife.`,
	Run: func(cmd *cobra.Command, args []string) {
		var ui core.UI
		supermarket.ValidateArgsAndType(args, query, ui)
		if !supermarket.ValidateArtifact(args[0]) {
			ui.Msg("only cookbook type artifact supported as of now.")
			os.Exit(1)
		}
		if len(query) < 1 {
			query = args[1]
		}
		var config core.Config
		config.Format = format
		sp := supermarket.NewSearchProvider(query, superMarketUri, args[0])
		sp.Search(ui, config)
		os.Exit(1)
	},
}

func init() {
	SupermarketCmd.AddCommand(supermarketSearchCmd)
	supermarketSearchCmd.PersistentFlags().StringVarP(&query, "query", "q", "", "will be use to search cookbook")
	supermarketSearchCmd.PersistentFlags().StringVarP(&format, "format", "f", "yaml", "Use to display result in format")

}
