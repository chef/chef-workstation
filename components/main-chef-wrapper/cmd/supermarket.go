/*
Copyright © 2022 NAME HERE <EMAIL ADDRESS>

*/
package cmd

import (
	chefcli "github.com/chef/go-chef-cli/cmd"
)

func init() {
	RootCmd.AddCommand(chefcli.SupermarketCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// SupermarketCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// SupermarketCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
