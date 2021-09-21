//
// Copyright 2020 Chef Software, Inc.
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

// TODO - Long descroiption can probably be auto-generated once we actually have the sub-sub subcommands  defined...
var generateCmd = &cobra.Command{
	Use:   "generate GENERATOR",
	Short: "Generate a new repository, cookbook, or other component",
	Long: `Generate a new repository, cookbook, or other component.
Available generators:
  cookbook        Generate a single cookbook
	recipe          Generate a single recipe
	attribute       Generate an attributes file
	template        Generate a file template
	file            Generate a cookbook file
	helpers         Generate a cookbook helper file in libraries/
	resource        Generate a custom resource
	repo            Generate a %s code repository
	policyfile      Generate a Policyfile for use with install/push commands
	generator       Copy %s's generator cookbook so you can customize it
	build-cookbook  Generate a build cookbook
`,

	RunE: func(cmd *cobra.Command, args []string) error {
		return PassThroughCommand(dist.WorkstationExec, "", os.Args[1:])
	},
}

func init() {
	// TODO - this should not be ClientProduct, it should be something like ProductGroup (Chef Infra)
	//         We need to check other usages for correctness.
	generateCmd.Long = fmt.Sprintf(generateCmd.Long, dist.ClientProduct, dist.WorkstationProduct)
	RootCmd.AddCommand(generateCmd)

}
