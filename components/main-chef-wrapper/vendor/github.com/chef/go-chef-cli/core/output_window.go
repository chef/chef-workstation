//go:build windows
// +build windows

package core

import (
	"runtime"

	"github.com/muesli/termenv"
)

func init() {
	if runtime.GOOS == "windows" {
		_, _ = termenv.EnableWindowsANSIConsole()
	}
}
