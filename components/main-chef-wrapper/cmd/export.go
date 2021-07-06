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
	force     bool
	exportCmd = &cobra.Command{
		Use:   "export [ Policyfile ] DESTINATION_DIRECTORY",
		Short: "Export a policy lock as a %s code repository",
		Long: `
Create a %s Zero-compatible repository containing the
cookbooks described in a Policyfile.lock.json. The exported repository also
contains a .chef/config.rb which configures %s to apply your policy.
Once the exported repo is copied to the target machine, you can apply
the policy to any machine with:

  $ %s -z

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
	exportCmd.Short = fmt.Sprintf(exportCmd.Short, dist.ClientProduct)
	exportCmd.Long = fmt.Sprintf(exportCmd.Long,
		dist.ClientProduct,
		dist.ClientProduct)
	exportCmd.PersistentFlags().BoolVarP(&force, "force", "f", false, "If the DESTINATION_DIRECTORY is not empty, remove its contents before exporting into it")
	exportCmd.PersistentFlags().BoolVarP(&force, "archive", "a", false, "Export as a tarball archive rather than a directory")

	rootCmd.AddCommand(exportCmd)
}
