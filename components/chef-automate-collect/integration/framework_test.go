package integration

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"runtime"
)

func ChefAutoCollect(args ...string) (bytes.Buffer, bytes.Buffer, int) {
	return runChefAutoCollectCmd("", args...)
}

func runChefAutoCollectCmd(workingDir string, args ...string) (stdout bytes.Buffer, stderr bytes.Buffer, exitcode int) {
	cmd := exec.Command(findChefAutoCollectBinary(), args...)
	cmd.Env = os.Environ()
	cmd.Stdout = &stdout
	cmd.Stderr = &stderr

	if len(workingDir) != 0 {
		cmd.Dir = workingDir
	}

	exitcode = 0
	if err := cmd.Run(); err != nil {
		if exitError, ok := err.(*exec.ExitError); ok {
			exitcode = exitError.ExitCode()
		} else {
			exitcode = 999
			fmt.Println(stderr)
			if _, err := stderr.WriteString(err.Error()); err != nil {
				// we should never get here but if we do, lets print the error
				fmt.Println(err)
			}
		}
	}
	return
}

func findChefAutoCollectBinary() string {
	if bin := os.Getenv("CHEF_AUTOCOLLECT_BIN"); bin != "" {
		return bin
	}

	if runtime.GOOS != "" && runtime.GOARCH != "" {
		return fmt.Sprintf("chef-automate-collect_%s_%s", runtime.GOOS, runtime.GOARCH)
	}

	return "chef-automate-collect"
}
