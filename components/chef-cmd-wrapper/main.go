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

	// At the very beginning we want to pass every sub-command to the old 'chef'
	// CLI binary that was renamed to 'chef-cli`, which is our default case.
	switch subCommand {
	// @afiune Adding a few example of the usability of this new top-level binary:
	//
	// 1) On the creation of new CLIs, for instance, a new CLI called chef-analyze that
	// will provide some analyze capabilities, as a user, you can run the binary directly
	// chef-analyze foo or through our main Chef CLI wrapper chef analyze foo.
	// Both ways would be running the same underlying binary.
	case "analyze":
		cmd = exec.Command("chef-analyze", allArgs...)

	// 2) Redirecting existing binaries to a single point for further improments, this
	// could be the case of improving, for example, our knife tool that could take a few
	// seconds to run simple API searches like 'knife node list'  or 'knife cookbook list'
	case "knife":
		cmd = exec.Command("knife", allArgs...)

	// 3) On replacements of current functionality, for example, if we would like to improve
	// the existing chef generate foo command, we would create a binary called chef-generate
	// that users can run individually like chef-generate foo and then redirect the top-level
	// CLI to run that same binary on any 'chef generate XYZ' execution.
	case "generate":
		// TODO @afiune design a better way to isolate single sub-commands that we want to
		// replace/improve, for instance we might not want to rewrite the entire 'chef generate'
		// sub-command but a section of it.
		//
		// Example of a sub-command overwrite
		if len(os.Args) > 2 && os.Args[2] == "build-cookbook" {
			fmt.Println("The sub-command 'chef generate build-cookbook' has been deprecated.")
			os.Exit(0)
		}
		fallthrough

	default:
		// When we land in the default case where we run the old 'chef' cli binary,
		// we need to send the sub-command as well as all the arguments.
		allArgs = append([]string{subCommand}, allArgs...)
		cmd = exec.Command("chef-cli", allArgs...)
	}

	debugLog(fmt.Sprintf("Bin: %s", cmd.Path))
	debugLog(fmt.Sprintf("Args: %v", allArgs))

	cmd.Env = os.Environ()
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	// TODO @afiune handle the errors in a way better manner
	if err := cmd.Run(); err != nil {
		if exitError, ok := err.(*exec.ExitError); ok {
			os.Exit(exitError.ExitCode())
		}
		// @afiune This might only be needed when doing debugging
		// because if we got here it means we have a different error
		// other than a 'ExitError' so print
		debugLog(fmt.Sprintf("Unexpected Error: \n%s", err))
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

`)
}

func debugLog(msg string) {
	if os.Getenv("DEBUG") == "true" {
		fmt.Println(msg)
	}
}
