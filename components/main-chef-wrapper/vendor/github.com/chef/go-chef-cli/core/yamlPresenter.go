package core

import (
	"bytes"

	yaml2 "gopkg.in/yaml.v3"
)

type YamlPresenter struct {
	separator string
	attr      string
	runList   string
}

func NewYamlPresenter(separator, attr, runList string) *YamlPresenter {
	return &YamlPresenter{
		separator: separator,
		attr:      attr,
		runList:   runList,
	}
}

// Format will format in pretty print
func (yp *YamlPresenter) Format(data interface{}) string {
	buff := new(bytes.Buffer)
	encoder := yaml2.NewEncoder(buff)
	encoder.SetIndent(4)
	err := encoder.Encode(data)
	if err != nil {
		d, _ := yaml2.Marshal(data)
		return string(d)
	}
	return buff.String()
}

// Summarize Summarize given input
func (yp *YamlPresenter) Summarize(data string) string { return "" }

// ListDisplay list display sort tje list and print result
func (yp *YamlPresenter) ListDisplay(config Config, data interface{}) interface{} { return nil }

// FormatSubSet will separate data on give input
func (yp *YamlPresenter) FormatSubSet(data string) string { return "" }

// NameOrID will print name or id
func (yp *YamlPresenter) NameOrID(data map[string]interface{}) interface{} { return nil }

// NestedValue will get all nested value matching to attr
func (yp *YamlPresenter) NestedValue(data interface{}) interface{} { return nil }

// DisplayCookBook will display cookbook in given format
func (yp *YamlPresenter) DisplayCookBook(data interface{}) interface{} { return nil }
