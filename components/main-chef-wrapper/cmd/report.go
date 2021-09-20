//
// Copyright 2020 Chef Software, Inc.
// Author: Marc A. Paradise <marc.paradise@gmail.com>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// LIMITATIONS UNDER THE LICENSE.
//

package cmd

import (
	"fmt"
	"os"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

var (
	nodeFilter   string
	format       string
	workers      int
	onlyUnused   bool
	runCookstyle bool
	anonymize    bool
	reportCmd    = &cobra.Command{
		Use:   "report",
		Short: fmt.Sprintf("Generate reports from a %s", dist.ServerProduct),
	}
	reportCookbooksCmd = &cobra.Command{
		Use:   "cookbooks",
		Short: "Generates a cookbook-oriented report",
		Args:  cobra.NoArgs,
		Long: `Generates a cookbook-oriented report containing details about the
upgrade compatibility errors and node cookbook usage.

The result is written to file.`,
		RunE: func(cmd *cobra.Command, args []string) error {
			return PassThroughCommand(dist.AnalyzeExec, "", os.Args[1:])
		},
	}

	reportNodesCmd = &cobra.Command{
		Use:   "nodes",
		Short: "Generates a nodes-oriented report",
		Long: `Generates a nodes-oriented report containing basic information about the node,
any applied policies, and the cookbooks used during the most recent chef-client run`,
		RunE: func(cmd *cobra.Command, args []string) error {
			return PassThroughCommand(dist.AnalyzeExec, "", os.Args[1:])
		},
	}
	uploadCmd = &cobra.Command{
		Use:    "report upload LOCATION FILE",
		Short:  fmt.Sprintf("Upload FILE to named LOCATION for %s to review", dist.CompanyName),
		Args:   cobra.ExactArgs(2),
		Hidden: true,
		RunE: func(cmd *cobra.Command, args []string) error {
			return PassThroughCommand(dist.AnalyzeExec, "", os.Args[1:])
		},
	}
	sessionCmd = &cobra.Command{
		Use:    "session MINUTES",
		Hidden: true,
		Short:  fmt.Sprintf("Creates new access credentials to upload files to %s. Expires in MINUTES.", dist.CompanyName),
		Args:   cobra.ExactArgs(1),
		RunE: func(cmd *cobra.Command, args []string) error {
			return PassThroughCommand(dist.WorkstationExec, "", os.Args[1:])
		},
	}
)

func init() {
	// Add shared infra/chef-server related flags
	addInfraFlagsToCommand(reportCmd)

	// common report flags
	reportCmd.PersistentFlags().StringVarP(
		&format,
		"format", "f", "txt",
		"output format: txt is human readable, csv is machine readable",
	)
	reportCmd.PersistentFlags().StringVarP(
		&nodeFilter,
		"node-filter", "F", "",
		"Search filter to apply to nodes",
	)

	// cookbooks cmd flags
	reportCookbooksCmd.PersistentFlags().IntVarP(
		&workers,
		"workers", "w", 50,
		"maximum number of parallel workers at once",
	)
	reportCookbooksCmd.PersistentFlags().BoolVarP(
		&onlyUnused,
		"only-unused", "u", false,
		"generate a report with only cookbooks that are not included in any node's runlist",
	)
	reportCookbooksCmd.PersistentFlags().BoolVarP(
		&runCookstyle,
		"verify-upgrade", "V", false,
		"verify the upgrade compatibility of every cookbook",
	)
	reportCmd.PersistentFlags().BoolVarP(
		&anonymize,
		"anonymize", "a", false,
		"replace cookbook and node names with hash values",
	)

	reportCmd.AddCommand(reportCookbooksCmd)
	reportCmd.AddCommand(reportNodesCmd)
	reportCmd.AddCommand(uploadCmd)
	reportCmd.AddCommand(sessionCmd)
	rootCmd.AddCommand(reportCmd)
}
