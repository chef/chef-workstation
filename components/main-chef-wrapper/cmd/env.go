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
// limitations under the License.
//

package cmd

import (
	"fmt"
	"os"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

var envCmd = &cobra.Command{
	Use:                "env",
	Short:              "Prints environment variables used by %s",
	DisableFlagParsing: true,
	RunE: func(cmd *cobra.Command, args []string) error {
		ReturnEnvironment()
		return nil
	},
}


func ReturnEnvironment() {
	err := platform_lib.Environment()
	if err != nil {
		fmt.Fprintln(os.Stderr, "ERROR:", err.Error())
		os.Exit(4)
	}
	os.Exit(0)
}

func init() {
	envCmd.Short = fmt.Sprintf(envCmd.Short, dist.WorkstationProduct)
	RootCmd.AddCommand(envCmd)
}
