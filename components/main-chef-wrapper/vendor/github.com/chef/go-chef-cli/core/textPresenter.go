package core

import (
	"encoding/json"
)

type TextPresenter struct {
	separator string
	attr      string
	runList   string
}

func NewTextPresenter(separator, attr, runList string) *TextPresenter {
	return &TextPresenter{
		separator: separator,
		attr:      attr,
		runList:   runList,
	}
}

// Format will format in pretty print
func (tp *TextPresenter) Format(data interface{}) string {
	d, _ := json.Marshal(data)
	return string(d)
}

// Summarize Summarize given input
func (tp *TextPresenter) Summarize(data string) string { return "" }

// ListDisplay list display sort tje list and print result
func (tp *TextPresenter) ListDisplay(config Config, data interface{}) interface{} { return nil }

// FormatSubSet will separate data on give input
func (tp *TextPresenter) FormatSubSet(data string) string { return "" }

// NameOrID will print name or id
func (tp *TextPresenter) NameOrID(data map[string]interface{}) interface{} { return nil }

// NestedValue will get all nested value matching to attr
func (tp *TextPresenter) NestedValue(data interface{}) interface{} { return nil }

// DisplayCookBook will display cookbook in given format
func (tp *TextPresenter) DisplayCookBook(data interface{}) interface{} { return nil }
