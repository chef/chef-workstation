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

var (
	attributes  bool
	excludeDeps bool

	updateCmd = &cobra.Command{
		Use:   "update [ POLICYFILE ] [cookbook1 [cookbook2 [...cookbookN] ] ] ",
		Short: "Updates a Policyfile.lock.json with the latest run_list and cookbooks",
		Long: `
This command reads the given POLICYFILE, applies any changes, resolves updated
dependencies within the constraints provided in the POLICYFILE, and replaces
'Policyfile.lock.json'.  The updated lockfile reflects changes to the 'run_list'
and includes any compatible dependency updates.

Individual dependent cookbooks (and their dependencies) may be updated by
passing their names after the POLICYFILE. The POLICYFILE parameter is mandatory
if you want to update individual cookbooks.

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
	undeleteCmd.PersistentFlags().BoolVar(&excludeDeps, "exclude-deps", false, "Only update cookbooks explicitly provided on the command line")
	// TODO - this is the first place we mention attributes. We should be discussing this as part of the default functionality
	// of the command in the long form help
	undeleteCmd.PersistentFlags().BoolVarP(&attributes, "attributes", "a", false, "Only update attributes (not cookbooks)")
	rootCmd.AddCommand(updateCmd)
}
