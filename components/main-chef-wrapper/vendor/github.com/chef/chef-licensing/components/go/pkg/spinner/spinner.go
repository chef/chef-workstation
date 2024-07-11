package spinner

import (
	"time"

	"github.com/theckman/yacspin"
)

func GetSpinner() (*yacspin.Spinner, error) {
	SpinnerConfig := yacspin.Config{
		Frequency:       100 * time.Millisecond,
		CharSet:         yacspin.CharSets[59],
		Suffix:          "License Validation",
		SuffixAutoColon: true,
	}

	return yacspin.New(SpinnerConfig)
}
