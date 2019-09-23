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

	// At the very beginning we want to pass every sub-command to the old
	// 'chef' CLI binary that was renamed to 'chef-cli`
	switch subCommand {
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
