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
	"errors"
	"fmt"
	"os"
	"os/exec"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

// Cobra usage notes

// 1. describe flag value parameter with backticks. This behavior is
// not documented clearly in the cobra or pflags libs, but backtick in
// the description allows us to the name the flag's parameter in help text.
//
// For example, this description:
//   "Read configuration from this path"
// Will give this help output:
//   -c, --config string   Read configuration from this path
//
// But using this one:
//   "Read configuration from `CONFIG_FILE_PATH`:
// Gives us:
//   -c, --config CONFIG_FILE_PATH  Read configuration from CONFIG_FILE_PATH
//
// The latter is more clear to the operator, so we prefer it.

type rootConfig struct {
	debug bool
}

var (
	options rootConfig

	rootCmd = &cobra.Command{
		Use: "chef",
		Short: `
The Chef command line tool for managing your infrastructure from your workstation.
Docs: https://docs.chef.io/workstation/
Patents: https://www.chef.io/patents
		`,
		// Stop framework from showing default errors. This prevents duplicate errors or
		// unncessary info from showing on passthrough commands; and
		// allows us control over error rendering for internal commands.
		SilenceErrors: false,

		// Don't spam the user with usage message when any error occurs -
		// this just makes it harder to see the actual message, obscuring it by dumping
		// a ton of usage text _after_ the meaningful message.
		// We can instead determine when we want to show usage, and do so.
		SilenceUsage: true,
	}
)

func Execute() {
	var ee *exec.ExitError
	if err := rootCmd.Execute(); err != nil {
		// fmt.Println(err.Error())
		if errors.As(err, &ee) {
			os.Exit(ee.ExitCode())
		}
		os.Exit(1)
	}
}

func init() {
	// Here you will define your flags and configuration settings.
	// Cobra supports persistent flags, which, if defined here,
	// will be global for your application.

	// TODO is there a a way to have these _only_ in child commands, without
	//      having them visible in root command? This would avoid us having to implement
	//      license handling prematurely in case someone wants to `chef --chef-license accept`

	// These flags are common to all child commands.  Some of them do not need config or debug,
	// so we can look at pushing this down; but it seems to make sense since it's present for more
	// commands than it isn't.
	rootCmd.PersistentFlags().BoolVarP(&options.debug, "version", "v", false,
		fmt.Sprintf("Show %s version information", dist.WorkstationProduct))
}

// TODO -
func passThroughCommand(targetPath string, cmdName string, args []string) error {

	var allArgs []string
	if cmdName != "" {
		allArgs = append([]string{cmdName}, args...)
	} else {
		allArgs = args
	}

	//
	cmd := exec.Command(targetPath, allArgs...)
	cmd.Env = os.Environ()
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	cmd.Stdin = os.Stdin

	return cmd.Run()

}
