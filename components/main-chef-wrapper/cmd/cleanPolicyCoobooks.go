//
// Copyright © 2021 Progress Software Corporation and/or its subsidiaries or affiliates. All Rights Reserved.
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

var cleanPolicyCoobooksCmd = &cobra.Command{
	Use:   "clean-policy-cookbooks",
	Short: "Delete unused Policyfile cookbooks on the %s",
	Long: `Delete unused Policyfile cookbooks.  Cookbooks are considered unused
when they are not referenced by any Policyfile revision on the %s.
This command will be most helpful when you first run "chef clean-policy-revisions"
in order to remove unreferenced Policy revisions.

See the policyfile documentation for more information:

https://docs.chef.io/policyfile/
`,
	RunE: func(cmd *cobra.Command, args []string) error {
		return Runner.passThroughCommand(dist.WorkstationExec, "", os.Args[1:])
	},
}

func init() {
	cleanPolicyCoobooksCmd.Short = fmt.Sprintf(cleanPolicyCoobooksCmd.Short,
		dist.ServerProduct)
	cleanPolicyCoobooksCmd.Long = fmt.Sprintf(cleanPolicyCoobooksCmd.Long,
		dist.ServerProduct)
	rootCmd.AddCommand(cleanPolicyCoobooksCmd)
}
