package integration

import (
	"bytes"
	"fmt"
	"os"
	"os/exec"
	"runtime"
)

// use this function to execute a real chef-analyze command, under the hood the function
// will detect the correct binary depending on the OS and Architecture this test is running
// from, if you need to override the binary to use, set the `CHEF_ANALYZE_BIN` environment
// variable to the path of the binary you wish to use.
//
// example:
//
//  func TestHelpCommand(t *testing.T) {
//    out, err, exitcode := ChefAnalyze("help")
//
//    assert.Contains(t,
//      out.String(),
//      "Use \"chef-analyze [command] --help\" for more information about a command.",
//      "STDOUT doesn't match")
//    assert.Empty(t,
//      err.String(),
//      "STDERR should be empty")
//    assert.Equal(t, 0, exitcode,
//      "EXITCODE is not the expected one")
//  }
//
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
