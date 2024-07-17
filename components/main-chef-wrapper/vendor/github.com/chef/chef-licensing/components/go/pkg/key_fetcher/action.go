package keyfetcher

import (
	"context"
	"errors"
	"fmt"
	"log"
	"os"
	"reflect"
	"strconv"
	"time"

	"github.com/chef/chef-licensing/components/go/pkg/api"
	"github.com/chef/chef-licensing/components/go/pkg/spinner"
	"github.com/cqroot/prompt"
	inputPrompt "github.com/cqroot/prompt/input"
	"github.com/gookit/color"
)

type PromptAttribute struct {
	TimeoutWarningColor string `yaml:"timeout_warning_color"`
	TimeoutDuration     int    `yaml:"timeout_duration"`
	TimeoutMessage      string `yaml:"timeout_message"`
	TimeoutContinue     bool   `yaml:"timeout_continue"`
}

type ActionDetail struct {
	Messages        []string          `yaml:"messages"`
	Options         []string          `yaml:"options,omitempty"`
	Action          string            `yaml:"action"`
	PromptType      string            `yaml:"prompt_type"`
	PromptAttribute PromptAttribute   `yaml:"prompt_attributes"`
	Paths           []string          `yaml:"paths"`
	ResponsePathMap map[string]string `yaml:"response_path_map"`
	Choice          string            `yaml:"choice"`
}

var lastUserInput string

func (ad ActionDetail) PerformInteraction() (nextID string) {
	var methodName string
	if ad.PromptType != "" {
		methodName = ad.PromptType
	} else if ad.Action != "" {
		methodName = ad.Action
	}

	meth := reflect.ValueOf(ad).MethodByName(methodName)
	returnVals := meth.Call(nil)

	if len(returnVals) > 0 {
		if returnValue, ok := returnVals[0].Interface().(string); ok {
			nextID = returnValue
		}
	} else {
		log.Fatal("Something went wrong with the interactions")
	}

	return
}

func (ad ActionDetail) Say() string {
	renderMessages(ad.Messages)
	return ad.Paths[0]
}

func (ad ActionDetail) TimeoutSelect() string {
	attribute := ad.PromptAttribute
	timeoutContext, cancel := context.WithTimeout(context.Background(), time.Second*time.Duration(attribute.TimeoutDuration))
	defer cancel()

	done := make(chan struct{})
	var val string
	var err error
	go func() {
		val, err = prompt.New().Ask(ad.Messages[0]).
			Choose(ad.Options)
		checkPromptErr(err)
		close(done)
	}()

	select {
	case <-done:
		if err == nil {
			fmt.Printf("Selected option: %s\n", val)
			return ad.ResponsePathMap[val]
		}
	case <-timeoutContext.Done():
		fmt.Printf(printInColor(attribute.TimeoutWarningColor, attribute.TimeoutMessage, false, true))
		fmt.Printf("Timeout!\n")
		if !attribute.TimeoutContinue {
			os.Exit(1)
		} else {
			return ad.ResponsePathMap["Skip"]
		}
	}
	return ""
}

func (ad ActionDetail) Ask() string {
	val, err := prompt.New().Ask(ad.Messages[0]).
		Input("license-key", inputPrompt.WithValidateFunc(validateLicenseFormat))
	if err != nil {
		if errors.Is(err, prompt.ErrUserQuit) {
			fmt.Fprintln(os.Stderr, "Error:", err)
			os.Exit(1)
		} else if errors.Is(err, ErrInvalidKeyFormat) {
			fmt.Fprintln(os.Stderr, err)
		} else {
			panic(err)
		}
	}
	SetLastUserInput(val)
	PromptInput.LicenseID = val

	return ad.Paths[0]
}

func (ad ActionDetail) Select() string {
	val1, err := prompt.New().Ask(ad.Messages[0]).
		Choose(ad.Options)
	checkPromptErr(err)

	return ad.ResponsePathMap[val1]
}

func (ad ActionDetail) SayAndSelect() string {
	renderMessages(ad.Messages)
	val1, err := prompt.New().Ask(ad.Choice).Choose(ad.Options)
	checkPromptErr(err)

	return ad.ResponsePathMap[val1]
}

func (ad ActionDetail) Warn() string {
	renderMessages(ad.Messages)

	return ad.Paths[0]
}

func (ad ActionDetail) Error() string {
	renderMessages(ad.Messages)

	return ad.Paths[0]
}

func (ad ActionDetail) Ok() string {
	renderMessages(ad.Messages)

	return ad.Paths[0]
}

func (ad ActionDetail) DoesLicenseHaveValidPattern() string {
	isValid := ValidateKeyFormat(GetLastUserInput())
	if isValid {
		return ad.ResponsePathMap["true"]
	} else {
		color.Warn.Println(ErrInvalidKeyFormat)
		return ad.ResponsePathMap["false"]
	}
}

func (ad ActionDetail) IsLicenseValidOnServer() string {
	spn, err := spinner.GetSpinner("License Validation")
	if err != nil {
		fmt.Printf("Unable to start the spinner\n")
	}
	spinner.StartSpinner(spn, "In Progress")

	isValid, message := api.GetClient().ValidateLicenseAPI(GetLastUserInput(), true)

	var stopChar string
	var stopColor string
	if isValid {
		stopChar = "✓"
		stopColor = "green"
	} else {
		stopChar = "✖"
		stopColor = "red"
		PromptInput.FailureMessage = message.Error()
	}
	spinner.StopSpinner(spn, "Done", stopChar, stopColor)
	return ad.ResponsePathMap[strconv.FormatBool(isValid)]
}

func (ad ActionDetail) FetchInvalidLicenseMessage() string {
	if PromptInput.FailureMessage == "" {
		_, message := api.GetClient().ValidateLicenseAPI(GetLastUserInput(), true)
		PromptInput.FailureMessage = message.Error()
	}
	return ad.Paths[0]
}

func (ad ActionDetail) IsLicenseAllowed() string {
	client, error := api.GetClient().GetLicenseClient([]string{GetLastUserInput()})
	if error != nil {
		log.Fatal(error)
	}
	licenseType := client.LicenseType
	PromptInput.LicenseType = licenseType
	if licenseType == "commercial" {
		PromptInput.IsCommercial = true
	}

	var isRestricted bool
	if IsLicenseRestricted(licenseType) {
		// Existing license keys needs to be fetcher to show details of existing license of license type which is restricted.
		// However, if user is trying to add Free Tier License, and user has active trial license, we fetch the trial license key
		var existingLicenseKeysInFile []string
		if licenseType == "free" && DoesUserHasActiveTrialLicense() {
			existingLicenseKeysInFile = FetchLicenseKeysBasedOnType(":trial")
		} else {
			existingLicenseKeysInFile = FetchLicenseKeysBasedOnType(":" + licenseType)
		}
		PromptInput.LicenseID = existingLicenseKeysInFile[len(existingLicenseKeysInFile)-1]
	} else {
		isRestricted = true
	}
	return ad.ResponsePathMap[strconv.FormatBool(isRestricted)]
}

func (ad ActionDetail) DetermineRestrictionType() string {
	var resType string
	if PromptInput.LicenseType == "free" && DoesUserHasActiveTrialLicense() {
		resType = "active_trial_restriction"
	} else {
		resType = PromptInput.LicenseType + "_restriction"
	}

	return ad.ResponsePathMap[resType]
}

func (ad ActionDetail) DisplayLicenseInfo() string {
	PrintLicenseKeyOverview([]string{GetLastUserInput()})
	return ad.Paths[0]
}

func (ad ActionDetail) FetchLicenseTypeRestricted() string {
	var val string
	if IsLicenseRestricted("trial") && IsLicenseRestricted("free") {
		val = "trial_and_free"
	} else if IsLicenseRestricted("trial") {
		val = "trial"
	} else {
		val = "free"
	}
	return ad.ResponsePathMap[val]
}

func (ad ActionDetail) CheckLicenseExpirationStatus() string {
	licenseClient := getLicense()
	var status string
	if licenseClient.IsExpired() || licenseClient.HaveGrace() {
		status = "expired"
	} else if licenseClient.IsAboutToExpire() {
		PromptInput.LicenseExpirationDate = licenseClient.LicenseExpirationDate().Format(time.UnixDate)
		PromptInput.ExpirationInDays = strconv.Itoa(licenseClient.ExpirationInDays())
		status = "about_to_expire"
	} else if licenseClient.IsExhausted() && (licenseClient.IsCommercial() || licenseClient.IsFree()) {
		status = "exhausted_license"
	} else {
		status = "active"
	}

	return ad.ResponsePathMap[status]
}

func (ad ActionDetail) FetchLicenseId() string {
	return ad.Paths[0]
}

func (ad ActionDetail) IsCommercialLicense() string {
	val := PromptInput.IsCommercial
	return ad.ResponsePathMap[strconv.FormatBool(val)]
}

func (ad ActionDetail) IsRunAllowedOnLicenseExhausted() string {
	val := PromptInput.IsCommercial

	return ad.ResponsePathMap[strconv.FormatBool(val)]
}

func (ad ActionDetail) FilterLicenseTypeOptions() string {
	var val string
	if IsLicenseRestricted("trial") && IsLicenseRestricted("free") || DoesUserHasActiveTrialLicense() {
		val = "ask_for_commercial_only"
	} else if IsLicenseRestricted("trial") {
		val = "ask_for_license_except_trial"
	} else if IsLicenseRestricted("free") {
		val = "ask_for_license_except_free"
	} else {
		val = "ask_for_all_license_type"
	}

	return ad.ResponsePathMap[val]
}

func (ad ActionDetail) SetLicenseInfo() string {
	SetLastUserInput(PromptInput.LicenseID)
	return ad.Paths[0]
}

func SetLastUserInput(val string) {
	lastUserInput = val
}

func GetLastUserInput() string {
	return lastUserInput
}
