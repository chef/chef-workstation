package cmd

import (
	"fmt"
	"os"
	"path/filepath"
)

func buildObservationLine(operation string, targetPath string, args []string, status string, err error) string {
	target := "-"
	if targetPath != "" {
		target = filepath.Base(targetPath)
	}

	line := fmt.Sprintf("INFO: op=%s target=%s argc=%d status=%s", operation, target, len(args), status)
	if err != nil {
		line = fmt.Sprintf("%s error=%q", line, err.Error())
	}

	return line
}

func emitCommandObservation(operation string, targetPath string, args []string, status string, err error) {
	fmt.Fprintln(os.Stderr, buildObservationLine(operation, targetPath, args, status, err))
}

func passThroughWithObservability(operation string, targetPath string, args []string) error {
	emitCommandObservation(operation, targetPath, args, "start", nil)
	err := Runner.PassThroughCommand(targetPath, "", args)
	if err != nil {
		emitCommandObservation(operation, targetPath, args, "error", err)
		return err
	}

	emitCommandObservation(operation, targetPath, args, "success", nil)
	return nil
}
