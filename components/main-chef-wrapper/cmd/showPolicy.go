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

// showPolicyCmd represents the showPolicy command
var (
	orphans         bool
	showPolicyPager bool

	showPolicyCmd = &cobra.Command{
		Use:   "show-policy [ POLICY_NAME [ POLICY_GROUP ] ]",
		Short: "Show policyfile objects on the %s",
		Long: `
Display the revisions of policyfiles on the %s.
By default, only active policy revisions are shown. Use the '--orphans'
option to show policy revisions that are not assigned to any policy group.

When both POLICY_NAME and POLICY_GROUP are given, the command shows the content
of the active policyfile lock for the given POLICY_GROUP. See also the 'diff'
command.

See the Policyfile documentation for more information:

https://docs.chef.io/policyfile/
`,
		DisableFlagParsing: true,

		RunE: func(cmd *cobra.Command, args []string) error {
			return passThroughCommand(dist.WorkstationExec, "", os.Args[1:])
		},
	}
)

func init() {
	showPolicyCmd.PersistentFlags().BoolVarP(&orphans, "orphans", "o", false, "Show policy revisions that are unassigned")
	// TODO - there are better tools for paging. Do we want to one-off support it here/in chef-cli?
	//        also in use for `diff`
	showPolicyCmd.PersistentFlags().BoolVar(&showPolicyPager, "[no-]pager", true, "Enable/disable paged policyfile lock output (default: enabled)")
	showPolicyCmd.Short = fmt.Sprintf(showPolicyCmd.Short, dist.ServerProduct)
	showPolicyCmd.Long = fmt.Sprintf(showPolicyCmd.Long, dist.ServerProduct)
	rootCmd.AddCommand(showPolicyCmd)
}
