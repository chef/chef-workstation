package core

import (
	"encoding/json"
	"sort"
)

type JsonPresenter struct {
	separator string
	attr      string
	runList   string
}

func NewJsonPresenter(separator, attr, runList string) *JsonPresenter {
	return &JsonPresenter{
		separator: separator,
		attr:      attr,
		runList:   runList,
	}
}

// Format will format in pretty print
func (jp *JsonPresenter) Format(data interface{}) string {
	val, err := json.MarshalIndent(data, "", "    ")
	if err != nil {
		val, _ := json.Marshal(data)
		return string(val)
	}
	return string(val)
}

// Summarize Summarize given input
func (jp *JsonPresenter) Summarize(data string) string { return "" }

// ListDisplay list display sort tje list and print result
func (jp *JsonPresenter) ListDisplay(config Config, data interface{}) interface{} {
	if len(config.WithUri) > 0 {
		return data
	}
	d, ok := data.(map[string]interface{})
	var result []string
	if ok {
		for keys, _ := range d {
			result = append(result, keys)
		}
	}
	sort.Strings(result)
	return result
}

// FormatSubSet will separate data on give input
func (jp *JsonPresenter) FormatSubSet(data string) string { return "" }

// NameOrID will print name or id
func (jp *JsonPresenter) NameOrID(data map[string]interface{}) interface{} { return nil }

// NestedValue will get all nested value matching to attr
func (jp *JsonPresenter) NestedValue(data interface{}) interface{} { return nil }

// DisplayCookBook will display cookbook in given format
func (jp *JsonPresenter) DisplayCookBook(data interface{}) interface{} { return nil }
