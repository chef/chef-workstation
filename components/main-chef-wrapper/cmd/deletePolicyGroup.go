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

// deletePolicyGroupCmd represents the deletePolicyGroup command
var deletePolicyGroupCmd = &cobra.Command{
	Use:   "delete-policy-group POLICY_GROUP",
	Short: "Delete a policy group on %s",
	Long: `Delete the policy group POLICY_GROUP on the configured %s.
Policy Revisions associated with the policy group are not deleted. The
state of the policy group will be backed up locally, allowing you to
undo this operation via the '%s undelete' command.

See our detailed README for more information:

https://docs.chef.io/policyfile/
`,
	Args:               cobra.ExactArgs(1),
	DisableFlagParsing: true,

	RunE: func(cmd *cobra.Command, args []string) error {
		return Runner.PassThroughCommand(dist.WorkstationExec, "", os.Args[1:])
	},
}

func init() {
	deletePolicyGroupCmd.Short = fmt.Sprintf(deletePolicyGroupCmd.Short, dist.ServerProduct)
	deletePolicyGroupCmd.Long = fmt.Sprintf(deletePolicyGroupCmd.Long, dist.ServerProduct, dist.CLIWrapperExec)
	RootCmd.AddCommand(deletePolicyGroupCmd)
}
