package cmd

import (
	"os"

	"github.com/chef/go-chef-cli/core"
	"github.com/chef/go-chef-cli/supermarket"
	"github.com/spf13/cobra"
)

var (
	fileName string
	force    bool
)

// supermarketSearchCmd represents the supermarket search
var supermarketDownloadCmd = &cobra.Command{
	Use:   "download <artifact-type> <artifact-name>",
	Short: "Use the download argument to download a cookbook from Chef Supermarket",
	Long:  `A cookbook will be downloaded as a tar.gz archive and placed in the current working directory. If a cookbook (or cookbook version) has been deprecated and the --force option is not used, chef will alert the user that the cookbook is deprecated and then will provide the name of the most recent non-deprecated version of that cookbook.`,
	Run: func(cmd *cobra.Command, args []string) {
		var ui core.UI
		supermarket.ValidateArgsAndType(args, "", ui)
		if !supermarket.ValidateArtifact(args[0]) {
			ui.Msg("only cookbook  artifact type is supported as of now.")
			os.Exit(1)
		}
		specificVersion := ""
		if len(args) > 2 {
			specificVersion = args[2]
		}
		var config core.Config
		config.Format = format
		dp := supermarket.NewDownloadProvider(args[1], superMarketUri, args[0], fileName, specificVersion, force)
		err := dp.Download(ui, config)
		if err != nil {
			ui.Error(err.Error())
		}
		os.Exit(1)
	},
}

func init() {
	SupermarketCmd.AddCommand(supermarketDownloadCmd)
	supermarketDownloadCmd.PersistentFlags().StringVarP(&fileName, "file", "f", "", "The filename to write to.")
	supermarketDownloadCmd.PersistentFlags().BoolVarP(&force, "force", "", false, "Force download deprecated version.")

}
