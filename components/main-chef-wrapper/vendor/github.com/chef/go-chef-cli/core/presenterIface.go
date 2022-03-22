package core

type Presenter interface {
	Format(data interface{}) string
	Summarize(data string) string
	ListDisplay(config Config, data interface{}) interface{}
	FormatSubSet(data string) string
	NameOrID(data map[string]interface{}) interface{}
	NestedValue(data interface{}) interface{}
	DisplayCookBook(data interface{}) interface{}
}
