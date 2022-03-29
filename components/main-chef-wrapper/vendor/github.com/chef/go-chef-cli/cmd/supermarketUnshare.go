/*
Copyright © 2022 Author: Nitin Sanghi <nsanghi@progress.com>

*/
package cmd

import (
	"fmt"
	"os"

	"github.com/chef/go-chef-cli/core"
	"github.com/chef/go-chef-cli/supermarket"
	"github.com/go-chef/chef"
	"github.com/spf13/cobra"
)

// supermarketSearchCmd represents the supermarket search
var supermarketUnShareCmd = &cobra.Command{
	Use:   "unshare",
	Short: "Use the unshare argument to stop the sharing of a cookbook located at Chef Supermarket.",
	Long:  `Use the unshare argument to stop the sharing of a cookbook located at Chef Supermarket. Only the maintainer of a cookbook may perform this action.`,
	Run: func(cmd *cobra.Command, args []string) {
		var ui core.UI
		supermarket.ValidateArgsAndType(args, query, ui)
		if !supermarket.ValidateArtifact(args[0]) {
			ui.Msg("only cookbook type artifact supported as of now.")
			os.Exit(1)
		}
		var c core.Config
		if !ui.ConfirmWithoutExit(config, "Do you really want to unshare all versions of the cookbook starter? (Y/N): ", false, 2) {
			ui.Msg("You said no, so I'm done here.")
			os.Exit(1)
		}
		data, path := c.LoadConfig(configPath)
		var cc chef.ConfigRb
		cc, err := chef.NewClientRb(data, path)
		if err != nil {
			ui.Fatal("No knife configuration file found. See https://docs.chef.io/config_rb/ for details.")
		}
		err = supermarket.UnShareCookbook(args[1], superMarketUri, cc.NodeName, cc.ClientKey)
		if err != nil {
			ui.Error(fmt.Sprintf("Forbidden: You must be the maintainer of %s to unshare it & %s must allow maintainers to unshare cookbooks.", args[1], superMarketUri))
			ui.Warn("The default supermarket https://supermarket.chef.io does not allow maintainers to unshare cookbooks.")
			os.Exit(1)
		}
		ui.Msg(fmt.Sprintf("Unshared all versions of the cookbook %s", args[1]))
		os.Exit(1)
	},
}

func init() {
	SupermarketCmd.AddCommand(supermarketUnShareCmd)
}

/*

{"Accept"=>"application/json",
 "Accept-Encoding"=>"gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
 "X-Ops-Server-API-Version"=>"2",
 "X-OPS-SIGN"=>"algorithm=sha1;version=1.1;",
 "X-OPS-USERID"=>"sanghinitin-p",
 "X-OPS-TIMESTAMP"=>"2022-03-15T06:54:47Z",
 "X-OPS-CONTENT-HASH"=>"2jmj7l5rSw0yVb/vlWAYkK/YBwk=",
 "X-OPS-AUTHORIZATION-1"=>"QvfB0LDjICmikj9dS2aafSsarf4Y54U9vl3Xns6gNe9SCfbYClLeIYuT2HaQ",
 "X-OPS-AUTHORIZATION-2"=>"DoC/0FvcdbuD+m/CyqfyMqNNjPXbiGbx8GCQNlaaLP8aM79GTV/t5xgGMWV3",
 "X-OPS-AUTHORIZATION-3"=>"/zraQ+HuHG4UmhtHBvvgDpOy8KNMK/RhgRkyNAgXkTrCVqO6dCYO8nuh78H6",
 "X-OPS-AUTHORIZATION-4"=>"Q0YFr8q2c3ifVPC9JcUKir0Uxz4SiuTo+KfVO68F2RzOJBw8Q3V8zd4c4qL5",
 "X-OPS-AUTHORIZATION-5"=>"V5Vtljaq618FGdZFD64NcOwg/7ApmP+BCBkvcUEQBIclqAQb9reWQ1yQuwuu",
 "X-OPS-AUTHORIZATION-6"=>"NcCeXtx1CzL48z/svtjnGu0BlbthXxC9qVkFzhKUjg==",
 "HOST"=>"supermarket.chef.io:443",
 "X-REMOTE-REQUEST-ID"=>"8c216075-c9c6-423d-82a3-9bab095bbf46"}

*/
