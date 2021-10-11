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

var pushArchiveCmd = &cobra.Command{
	Use:   "push-archive POLICY_GROUP ARCHIVE_FILE",
	Short: "Push a policy archive to a policy group on the %s",
	Long: `
Publish a policy archive to a %s.

Policy archives can be created with '%s export -a'. The policy will be
applied to the given POLICY_GROUP, which is a set of nodes that share the
same run_list and cookbooks.

See the policyfile documentation for more information:

https://docs.chef.io/policyfile/
`,
	DisableFlagParsing: true,

	RunE: func(cmd *cobra.Command, args []string) error {
		return Runner.passThroughCommand(dist.WorkstationExec, "", os.Args[1:])
	},
}

func init() {
	pushArchiveCmd.Short = fmt.Sprintf(pushArchiveCmd.Short, dist.ServerProduct)
	pushArchiveCmd.Long = fmt.Sprintf(pushArchiveCmd.Long,
		dist.ServerProduct,
		dist.CLIWrapperExec)
	rootCmd.AddCommand(pushArchiveCmd)

}
