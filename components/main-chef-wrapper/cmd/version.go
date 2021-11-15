// +build !integration
// +build !unit

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

package cmd

import (
	"fmt"
	"os"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	platform_lib "github.com/chef/chef-workstation/components/main-chef-wrapper/platform-lib"
	"github.com/spf13/cobra"
)

var versionCmd = &cobra.Command{
	Use:                "version",
	Hidden:             true,
	DisableFlagParsing: true,
	RunE: func(cmd *cobra.Command, args []string) error {
		CheckVersion()
		return nil
	},
}

func CheckVersion() {
	err := platform_lib.Version()
	if err != nil {
		fmt.Fprintln(os.Stderr, "ERROR:", err.Error())
		os.Exit(4)
	}
	os.Exit(0)

}

func init() {
	versionCmd.Short = fmt.Sprintf(versionCmd.Short, dist.WorkstationProduct)
	RootCmd.AddCommand(versionCmd)
}
