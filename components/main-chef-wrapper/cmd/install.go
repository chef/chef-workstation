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

var installCmd = &cobra.Command{
	Use:   "install [ POLICYFILE_PATH ]",
	Short: "Install cookbooks from a policyfile and generate a locked cookbook set",
	Long: `

Evaluate POLICYFILE_PATH to find a compatible set of cookbooks for the
policy's run_list and cache them locally.  Create or update the Policyfile.lock.json
to describe the locked cookbook set. You can use the lockfile to install the locked
cookbooks on another machine.

You can also push the lockfile to a "policy group" on a %s and
apply that exact set of cookbooks to nodes in your infrastructure.

See the policyfile documentation for more information:

https://docs.chef.io/policyfile/
`,
	DisableFlagParsing: true,
	RunE: func(cmd *cobra.Command, args []string) error {
		return Runner.passThroughCommand(dist.WorkstationExec, "", os.Args[1:])
	},
}

func init() {
	installCmd.Long = fmt.Sprintf(installCmd.Long, dist.ServerProduct)
	rootCmd.AddCommand(installCmd)
}
