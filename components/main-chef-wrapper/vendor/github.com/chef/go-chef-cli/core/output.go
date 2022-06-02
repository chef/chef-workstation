package core

import (
	"fmt"
	"os"
	"strings"

	"github.com/muesli/termenv"
)

const colorRed = "#FF0000"
const colorBlue = "#0000FF"
const colorYellow = "#FFFF00"
const jsonFormat = "json"
const yamlFormat = "yaml"
const textFormat = "text"

// UI will used to display current output in format and color
type UI struct {
	color          string
	logLevel       string
	fieldSeparator string
	trmColor       termenv.Color
}

func (u *UI) ColorMsg(message, color string) string {
	switch color {
	case "yellow":
		return colorMessage(message, colorYellow)
	case "red":
		return colorMessage(message, colorRed)
	case "blue":
		return colorMessage(message, colorBlue)
	}
	return message
}

// NewUI return new UI object
func NewUI(color, format, logLevel, fieldSep string) *UI {
	return &UI{
		color:          color,
		logLevel:       logLevel,
		fieldSeparator: fieldSep,
	}
}

func (u *UI) Output(config Config, data interface{}) {
	switch config.Format {
	case jsonFormat:
		var jp JsonPresenter
		u.Msg(jp.Format(data))
	case yamlFormat:
		var yp YamlPresenter
		u.Msg(yp.Format(data))
	case textFormat:
		var tp TextPresenter
		u.Msg(tp.Format(data))
	default:
		var jp JsonPresenter
		u.Msg(jp.Format(data))
	}
}

// Msg will print give data with give color and format
func (u *UI) Msg(message string) {
	fmt.Println(message)
}
func colorMessage(message, colorType string) string {
	tColor := termenv.ColorProfile().Color(colorType)
	return termenv.String(message).Foreground(tColor).Bold().String()
}

// Debug Print a debug
func (u *UI) Debug(message string) {
	fmt.Println(colorMessage("DEBUG:", colorBlue), message)
}

// Warn Print a warning message
func (u *UI) Warn(message string) {
	fmt.Println(colorMessage("WARNING:", colorYellow), message)
}

// Error print an error Msg
func (u *UI) Error(message string) {
	fmt.Println(colorMessage("ERROR:", colorRed), message)
}

// Fatal Print a message describing a fatal error
func (u *UI) Fatal(message string) {
	fmt.Println(colorMessage("FATAL:", colorRed), message)
	os.Exit(1)
}

func (u *UI) AskQuestion(config Config, question string, opts map[string]string) (ans string) {
	if _, ok := opts["default"]; ok {
		question += fmt.Sprintf("[%s]", opts["default"])
	}
	if ans, ok := opts["default"]; ok && config.DefaultValue {
		return ans
	} else {
		fmt.Println(question)
		fmt.Scanln(&ans)
		if len(ans) > 0 {
			return ans
		}
		return opts["default"]
	}
}

// ConfirmationInstructions instruction shown to user
func (u *UI) ConfirmationInstructions(defaultChoice int) string {
	switch defaultChoice {
	case 1:
		return "? (Y/n) "
	case 2:
		return "? (y/N) "
	}
	return "? (Y/N) "
}

// ConfirmWithoutExit ask user question based on that program continue
func (u *UI) ConfirmWithoutExit(config Config, question string, appendInstructions bool, defaultChoice int) bool {
	if config.DefaultValue {
		return true
	}
	fmt.Print(question)
	if appendInstructions {
		u.Msg(u.ConfirmationInstructions(defaultChoice))
	}
	var ans string
	fmt.Scanln(&ans)
	ans = strings.ToLower(ans)
	if ans == "y" {
		return true
	} else if ans == "n" {
		return false
	} else {
		if defaultChoice == 1 {
			return true
		} else if defaultChoice == 2 {
			return false
		}
	}
	u.Msg(fmt.Sprintf("I have no idea what to do with '%s'", ans))
	u.Msg("Just say Y or N, please.")
	return u.ConfirmWithoutExit(config, question, appendInstructions, defaultChoice)
}

// Confirm ask user question based on that program continue
func (u *UI) Confirm(config Config, question string, appendInstructions bool, defaultChoice int) {
	if !u.ConfirmWithoutExit(config, question, appendInstructions, defaultChoice) {
		os.Exit(3)
	}
}
