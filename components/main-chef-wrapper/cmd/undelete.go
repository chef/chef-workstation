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

var (
	list        bool
	id          string
	undeleteCmd = &cobra.Command{
		Use:   "undelete",
		Short: "Undo a delete command",
		Long: `
Recover a deleted policy or policy group. When run with no arguments, it lists the
available undo operations. To undo the last delete operation, use '%s undelete --last'.

CAVEATS:

* '%s undelete' doesn't detect conflicts. If a deleted item has been recreated,
  running '%s undelete' will overwrite it.
* Undo information does not include cookbooks that might be referenced by
  policies. If you have cleaned the policy cookbooks after the delete operation
  you want to reverse, '%s undelete' may not be able to fully restore the
  previous state.
* The delete commands do not store access control data, so you may have to
manually reapply any ACL customizations you have made.

See the policyfile documentation for more information:

https://docs.chef.io/policyfile/
`,
		RunE: func(cmd *cobra.Command, args []string) error {
			return Runner.PassThroughCommand(dist.WorkstationExec, "", os.Args[1:])
		},
	}
)

func init() {
	undeleteCmd.Long = fmt.Sprintf(undeleteCmd.Long,
		dist.CLIWrapperExec,
		dist.CLIWrapperExec,
		dist.CLIWrapperExec)

	undeleteCmd.PersistentFlags().BoolVarP(&list, "last", "l", false, "Undo the most recent delete operation")
	undeleteCmd.PersistentFlags().StringVarP(&id, "id", "i", "", "Undo the delete operation referenced by the given `ID`")
	RootCmd.AddCommand(undeleteCmd)
}
