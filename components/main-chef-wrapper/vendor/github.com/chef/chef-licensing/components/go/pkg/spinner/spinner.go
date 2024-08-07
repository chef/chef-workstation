package spinner

import (
	"os"
	"time"

	"github.com/theckman/yacspin"
	"golang.org/x/term"
)

func GetSpinner(suffix string) (*yacspin.Spinner, error) {
	if !IsTTY() {
		// In case the TTY is not available, suppress the spinner
		suffix = ""
	}

	SpinnerConfig := yacspin.Config{
		Frequency:       100 * time.Millisecond,
		CharSet:         yacspin.CharSets[59],
		Suffix:          suffix,
		SuffixAutoColon: true,
	}

	return yacspin.New(SpinnerConfig)
}

func StartSpinner(spinner *yacspin.Spinner, message string) {
	if IsTTY() {
		spinner.Message(message)
		_ = spinner.Start()
	}

}

func StopSpinner(spinner *yacspin.Spinner, stopMessage, stopChar, stopColor string) {
	if IsTTY() {
		spinner.StopMessage(stopMessage)
		spinner.StopCharacter(stopChar)
		spinner.StopColors(stopColor)
		_ = spinner.Stop()
	}
}

func IsTTY() bool {
	return term.IsTerminal(int(os.Stdout.Fd()))
}
