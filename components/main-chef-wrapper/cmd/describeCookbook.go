//
// Copyright 2020 Chef Software, Inc.
//
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
	"os"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

var describeCookbookCmd = &cobra.Command{
	Use:                "describe-cookbook COOKBOOK_PATH",
	Short:              "Prints cookbook checksum information for the cookbook at COOKBOOK_PATH",
	DisableFlagParsing: true,
	RunE: func(cmd *cobra.Command, args []string) error {
		return Runner.passThroughCommand(dist.WorkstationExec, "", os.Args[1:])
	},
}

func init() {
	rootCmd.AddCommand(describeCookbookCmd)
}
