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

// shellInitCmd represents the shellInit command
var shellInitCmd = &cobra.Command{
	Use:   "shell-init ",
	Short: "Set shell context to the %s environment",

	Long: `
'%s shell-init' modifies your shell environment to make %s your
default Ruby.

  To enable for just the current shell session:

    In sh, bash, and zsh:
      eval "$(%s shell-init SHELL_NAME)"
    In fish:
      eval (%s shell-init fish)
    In Powershell:
      chef shell-init powershell | Invoke-Expression

  To permanently enable:

    In sh, bash, and zsh:
      echo 'eval "$(%s shell-init SHELL_NAME)"' >> ~/.YOUR_SHELL_RC_FILE
    In fish:
      echo 'eval (%s shell-init SHELL_NAME)' >> ~/.config/fish/config.fish
    In Powershell
      "chef shell-init powershell | Invoke-Expression" >> $PROFILE
`,
	RunE: func(cmd *cobra.Command, args []string) error {
		return passThroughCommand(dist.WorkstationExec, "", os.Args[1:])
	},
}

func init() {
	shellInitCmd.Short = fmt.Sprintf(shellInitCmd.Short, dist.WorkstationProduct)
	shellInitCmd.Long = fmt.Sprintf(shellInitCmd.Long,
		dist.CLIWrapperExec,
		dist.WorkstationProduct,
		dist.CLIWrapperExec,
		dist.CLIWrapperExec,
		dist.CLIWrapperExec,
		dist.CLIWrapperExec)

	// TODO - not adding '--omnibus-dir' flag which was documented for testing only.
	rootCmd.AddCommand(shellInitCmd)
}
