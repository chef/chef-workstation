//
// Copyright © 2021 Progress Software Corporation and/or its subsidiaries or affiliates. All Rights Reserved.
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

// TODO - capture command does _not_ want the inherited config flag, I think that will cuase confusion
//        since we don't support chef-config style here.
var (
	downloadDataBags bool
	captureCmd       = &cobra.Command{
		Use:   "capture NODE-NAME",
		Short: "Capture a node's state into a local chef-repo",
		Args:  cobra.ExactArgs(1),
		Long: `
Captures a node's state as a local chef-repo, which can then be used to
converge locally.
`,
		DisableFlagParsing: true,
		RunE: func(cmd *cobra.Command, args []string) error {
			return Runner.passThroughCommand(dist.AnalyzeExec, "", os.Args[1:])
		},
	}
)

func init() {
	// TODO - this is a change for compatibilty with global "d"ebug flag.
	//        this code is "D", we will need to update main-chef-wrapper with this change.
	captureCmd.PersistentFlags().BoolVarP(
		&downloadDataBags,
		"with-data-bags",
		"D", false,
		"download all data bags as part of node capture",
	)
	AddInfraFlagsToCommand(captureCmd)

	RootCmd.AddCommand(captureCmd)
}
