//
// Copyright 2019 Chef Software, Inc.
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

package main

import (
	"fmt"
	"os"
	"os/exec"
)

func main() {
	// No arguments provided, display usage
	if len(os.Args) <= 1 {
		usage()
		os.Exit(0)
	}
	var (
		subCommand = os.Args[1]
		allArgs    = os.Args[2:]
		cmd        *exec.Cmd
	)

	switch subCommand {
	// 1) On the creation of new CLIs, for instance, a new CLI called chef-analyze that
	// will provide some analyze capabilities, as a user, you can run the binary directly
	// 'chef-analyze foo' or through our main Chef CLI wrapper 'chef analyze foo'.
	// Both ways would be running the same underlying binary.
	case "analyze":
		cmd = exec.Command("chef-analyze", allArgs...)

	// 2) Redirecting existing binaries to a single point for further improvements, this gives
	// the potential to transition some commands at a more granular level too - for example
	// 'knife search' can run a different a different binary than 'knife bootstrap'.
	//
	// TODO @afiune Propose this new behavior with the Team
	//case "knife":
	//cmd = exec.Command("knife", allArgs...)

	// 3) On replacements of current functionality, for example, if we would like to improve
	// the existing chef generate foo command, we would create a binary called chef-generate
	// that users can run individually like chef-generate foo and then redirect the top-level
	// CLI to run that same binary on any 'chef generate XYZ' execution.

	// We want to pass every sub-command to the old 'chef' CLI binary that was renamed to
	// 'chef-cli`, which is our default case.
	default:
		// When we land in the default case where we run the old 'chef' cli binary,
		// we need to send the sub-command as well as all the arguments.
		allArgs = append([]string{subCommand}, allArgs...)
		cmd = exec.Command("chef-cli", allArgs...)
	}

	debugLog(fmt.Sprintf("Chef binary: %s", cmd.Path))
	debugLog(fmt.Sprintf("Arguments: %v", allArgs))

	cmd.Env = os.Environ()
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	// TODO @afiune handle the errors in a better way
	if err := cmd.Run(); err != nil {
		if exitError, ok := err.(*exec.ExitError); ok {
			os.Exit(exitError.ExitCode())
		}
		// @afiune if we got here it means we have a different error
		// other than a 'ExitError', things like 'executable not found'
		fmt.Fprintln(os.Stderr, "ERROR:", err.Error())
		os.Exit(7)
	}
}

func usage() {
	// TODO @afiune add actual usage, this might only list top level sub-commands
	// we should avoid to add specific options per sub-command
	fmt.Printf(`Usage:
    chef -h/--help
    chef -v/--version
    chef command [arguments...] [options...]

Available Commands:
    exec                    Runs the command in context of the embedded ruby
    env                     Prints environment variables used by Chef Workstation
    gem                     Runs the 'gem' command in context of the embedded Ruby
    generate                Generate a new repository, cookbook, or other component
    shell-init              Initialize your shell to use Chef Workstation as your primary Ruby
    install                 Install cookbooks from a Policyfile and generate a locked cookbook set
    update                  Updates a Policyfile.lock.json with latest run_list and cookbooks
    push                    Push a local policy lock to a policy group on the Chef Infra Server
    push-archive            Push a policy archive to a policy group on the Chef Infra Server
    show-policy             Show policyfile objects on the Chef Infra Server
    diff                    Generate an itemized diff of two Policyfile lock documents
    export                  Export a policy lock as a Chef Infra Zero code repo
    clean-policy-revisions  Delete unused policy revisions on the Chef Infra Server
    clean-policy-cookbooks  Delete unused policyfile cookbooks on the Chef Infra Server
    delete-policy-group     Delete a policy group on the Chef Infra Server
    delete-policy           Delete all revisions of a policy on the Chef Infra Server
    undelete                Undo a delete command
    describe-cookbook       Prints cookbook checksum information used for cookbook identifier
`)
}

func debugLog(msg string) {
	if os.Getenv("DEBUG") == "true" {
		fmt.Fprintln(os.Stderr, "DEBUG: "+msg)
	}
}
