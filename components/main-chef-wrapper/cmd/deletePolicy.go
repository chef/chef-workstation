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
	"fmt"
	"os"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

// deletePolicyCmd represents the deletePolicy command
var deletePolicyCmd = &cobra.Command{
	Use:   "delete-policy POLICY_NAME",
	Short: "Delete all revisions of POLICY_NAME policy on the %s",
	Long: `
Delete all revisions of the policy POLICY_NAME on the configured
%s. All policy revisions will be backed up locally, allowing you to
undo this operation via the '%s undelete' command.
`,
	DisableFlagParsing: true,
	RunE: func(cmd *cobra.Command, args []string) error {
		return Runner.PassThroughCommand(dist.WorkstationExec, "", os.Args[1:])
	},
}

func init() {
	deletePolicyCmd.Short = fmt.Sprintf(deletePolicyCmd.Short, dist.ServerProduct)
	deletePolicyCmd.Long = fmt.Sprintf(deletePolicyCmd.Long, dist.ServerProduct, dist.CLIWrapperExec)

	RootCmd.AddCommand(deletePolicyCmd)
}
