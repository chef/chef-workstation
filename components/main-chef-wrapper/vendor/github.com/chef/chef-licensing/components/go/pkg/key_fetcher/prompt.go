package keyfetcher

import (
	"errors"
	"fmt"
	"log"
	"os"
	"reflect"
	"text/template"

	"github.com/chef/chef-licensing/components/go/pkg/api"
	"github.com/chef/chef-licensing/components/go/pkg/config"
	"github.com/chef/chef-licensing/components/go/pkg/spinner"
	"github.com/cqroot/prompt"
	"github.com/gookit/color"
	"gopkg.in/yaml.v2"
)

func StartInteractions(startID string) (keys []string) {
	if startID == "" {
		startID = "start"
	}
	initializePromptInputs()
	// var performedInteractions []string
	currentID := startID
	previousID := ""
	interactions := getIntractions()

	for {
		action := interactions[currentID]
		if currentID == "" || currentID == "exit" {
			break
		}
		// performedInteractions = append(performedInteractions, currentID)
		previousID = currentID
		currentID = action.PerformInteraction()
	}
	if currentID != "exit" {
		log.Fatal("Something went wrong in the flow. The last interaction was " + previousID)
	}
	if GetLastUserInput() != "" {
		keys = append(keys, GetLastUserInput())
	}

	// fmt.Println("Completed", performedInteractions)
	return
}

func UpdatePromptInputs(conf map[string]string) {
	v := reflect.ValueOf(&PromptInput).Elem()
	for key, value := range conf {
		field := v.FieldByName(key)
		if !field.IsValid() {
			continue
		}
		if !field.CanSet() {
			continue
		}

		field.SetString(value)
	}
}

func checkPromptErr(err error) {
	if err != nil {
		if errors.Is(err, prompt.ErrUserQuit) {
			fmt.Fprintln(os.Stderr, "Error:", err)
			os.Exit(1)
		} else {
			panic(err)
		}
	}
}

func initializePromptInputs() {
	m := make(map[string]string)
	conf := config.GetConfig()
	m["ProductName"] = conf.ProductName
	m["ChefExecutableName"] = conf.ExecutableName
	if conf.ExecutableName == "chef" {
		m["UnitMeasure"] = "nodes"
	} else {
		m["UnitMeasure"] = "targets"
	}
	UpdatePromptInputs(m)
}

func getIntractions() map[string]ActionDetail {
	var intr Interaction
	err := yaml.Unmarshal(interactionsYAML, &intr)
	if err != nil {
		log.Fatal(err)
	}
	return intr.Actions
}

func renderMessages(messages []string) {
	if len(messages) == 0 {
		return
	}

	for _, message := range messages {
		tmpl, err := template.New("actionMessage").Funcs(template.FuncMap{
			"printHyperlink":         printHyperlink,
			"printInColor":           printInColor,
			"printBoldText":          printBoldText,
			"printLicenseAddCommand": printLicenseAddCommand,
		}).Parse(message)
		if err != nil {
			log.Fatalf("error parsing template: %v", err)
		}
		fmt.Printf("\n")

		err = tmpl.Execute(os.Stdout, PromptInput)
		if err != nil {
			log.Fatalf("error executing template: %v", err)
		}
	}
}

func printHyperlink(url string) string {
	return color.Style{color.FgGreen, color.OpUnderscore}.Sprintf(url)
}

func printInColor(selColor, text string, options ...bool) string {
	output := color.Style{}
	var underline bool
	var bold bool

	if len(options) == 1 {
		underline = options[0]
	}
	if len(options) > 1 {
		bold = options[1]
	}

	switch selColor {
	case "red":
		output = append(output, color.FgRed)
	case "green":
		output = append(output, color.FgGreen)
	case "blue":
		output = append(output, color.FgBlue)
	case "yellow":
		output = append(output, color.FgYellow)
	}

	if underline {
		output = append(output, color.OpUnderscore)
	}
	if bold {
		output = append(output, color.OpBold)
	}

	return output.Sprintf(text)
}

func printBoldText(text1, text2 string) string {
	return color.Bold.Sprintf(text1 + " " + text2)
}

func printLicenseAddCommand() string {
	return printInColor("", PromptInput.ChefExecutableName+" license add", false, true)
}

func validateLicenseFormat(key string) error {
	isValid := ValidateKeyFormat(key)
	if isValid {
		return nil
	} else {
		return fmt.Errorf("%s: %w", key, ErrInvalidKeyFormat)
	}
}

func getLicense() api.LicenseClient {
	spn, err := spinner.GetSpinner("License Validation")
	if err != nil {
		fmt.Printf("Unable to start the spinner\n")
	}
	spinner.StartSpinner(spn, "In Progress")
	client, _ := api.GetClient().GetLicenseClient([]string{PromptInput.LicenseID})
	spinner.StopSpinner(spn, "", "", "")

	return *client
}
