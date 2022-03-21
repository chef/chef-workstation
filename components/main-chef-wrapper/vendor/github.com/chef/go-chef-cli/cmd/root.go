/*
Copyright © 2022 Progress Software Corporation and/or its subsidiaries or affiliates. All Rights Reserved.
Author: Nitin Sanghi <nsanghi@progress.com>

Licensed under the Apache License, version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
LIMITATIONS UNDER THE LICENSE.
*/

package cmd

import (
	"github.com/chef/go-chef-cli/core"
	"github.com/spf13/cobra"
)

var config core.Config
var cfgFile string

// rootCmd represents the base command when called without any subcommands
var rootCmd = &cobra.Command{
	Use:   "knife",
	Short: "knife is a command-line tool that provides an interface between a local chef-repo and the Chef Infra Server. knife helps users to manage",
	Long: `knife is a command-line tool that provides an interface between a local chef-repo and the Chef Infra Server. knife helps users to manage:
			Nodes
			Cookbooks and recipes
			Roles, Environments, and Data Bags
			Resources within various cloud environments
			The installation of Chef Infra Client onto nodes
			Searching of indexed data on the Chef Infra Server.`,
	CompletionOptions: cobra.CompletionOptions{
		DisableDefaultCmd: true,
	},
}

// Execute adds all child commands to the root command and sets flags appropriately.
// This is called by main.main(). It only needs to happen once to the rootCmd.
func Execute() error {
	return rootCmd.Execute()

}

func init() {
	// Here you will define your flags and configuration settings.
	// Cobra supports persistent flags, which, if defined here,
	// will be global for your application.

	rootCmd.PersistentFlags().StringVar(&cfgFile, "config", "", "config file location (default is $HOME/.chef)")

	// Cobra also supports local flags, which will only run
	// when this action is called directly.
}
