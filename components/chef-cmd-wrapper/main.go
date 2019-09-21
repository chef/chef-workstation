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
		os.Exit(3)
	}
	var (
		subCommand = os.Args[1]
		allArgs    = os.Args[1:]
		cmd        *exec.Cmd
	)

	// At the very beginning we want to pass every sub-command to the old
	// 'chef' CLI binary that was renamed to 'chef-cli`
	switch subCommand {
	default:
		cmd = exec.Command("chef-cli", allArgs...)
	}

	cmd.Env = os.Environ()
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr

	// TODO @afiune handle the errors in a way better manner
	if err := cmd.Run(); err != nil {
		// @afiune This might be only needed when doing debugging
		if os.Getenv("DEBUG") == "true" {
			fmt.Printf("ERROR FROM MAIN WRAPPER:\n%s", err)
		}
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
