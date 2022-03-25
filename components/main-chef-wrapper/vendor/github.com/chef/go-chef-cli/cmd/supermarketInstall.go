package cmd

import (
	"os"
	"path/filepath"
	"regexp"

	"github.com/chef/go-chef-cli/core"
	"github.com/chef/go-chef-cli/supermarket"
	"github.com/go-chef/chef"
	"github.com/spf13/cobra"
)

var (
	noDeps           bool
	cookBookPath     string
	defaultBranch    string
	useCurrentBranch bool
)

// supermarketSearchCmd represents the supermarket search
var supermarketInstallCmd = &cobra.Command{
	Use:   "install",
	Short: "install command will install cookbook that has been downloaded from Chef Supermarket to a local git repository",
	Long:  `install command will install cookbook that has been downloaded from Chef Supermarket to a local git repository. This action uses the git version control system in conjunction with Chef Supermarket site to install community-contributed cookbooks to the local chef-repo.`,
	Run: func(cmd *cobra.Command, args []string) {
		var ui core.UI
		supermarket.ValidateArgsAndType(args, "", ui)
		if !supermarket.ValidateArtifact(args[0]) {
			ui.Msg("only cookbook type artifact supported as of now.")
			os.Exit(1)
		}
		if len(args) >= 3 {
			version, _ := regexp.MatchString(`(\d+)(\.\d+){1,2}`, args[2])
			if !version {
				ui.Fatal("Installing multiple cookbooks at once is not supported.")
			}
		}
		installPath := ""
		if len(cookBookPath) > 1 {
			installPath = cookBookPath
		} else {
			installPath = core.GetDefaultConfigPath()
		}
		var config core.Config
		config.Format = format
		ci := supermarket.NewInstallProvider(args[1], superMarketUri, installPath, defaultBranch, args[0], noDeps, useCurrentBranch)
		ci.Install(ui, config)
		if !ci.InstallDeps() {
			m, err := chef.ReadMetaData(filepath.Join(installPath, args[1]))
			if err != nil {
				ui.Error("unable to read meta file: " + err.Error())
				os.Exit(1)
			}
			for name := range m.Depends {
				ci.ChangeArtifactName(name)
				ci.Install(ui, config)
			}
		}
	},
}

func init() {
	SupermarketCmd.AddCommand(supermarketInstallCmd)
	// supermarketInstallCmd.PersistentFlags().StringVarP(&superMarketUri, "supermarket-site", "m", "https://supermarket.chef.io", "will be use to search cookbook")
	supermarketInstallCmd.PersistentFlags().StringVarP(&cookBookPath, "cookbook-path", "o", "", "A colon-separated path to look for cookbooks in.")
	supermarketInstallCmd.PersistentFlags().StringVarP(&defaultBranch, "branch", "B", "master", "Default branch to work with.")
	supermarketInstallCmd.PersistentFlags().BoolVarP(&noDeps, "skip-dependencies", "D", false, "Skips automatic dependency installation.")
	supermarketInstallCmd.PersistentFlags().BoolVarP(&useCurrentBranch, "use-current-branch", "b", false, "Use the current branch.")

}
