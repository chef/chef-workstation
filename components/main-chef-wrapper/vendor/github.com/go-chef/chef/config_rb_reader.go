package chef

import (
	"errors"
	"io/ioutil"
	"path/filepath"
	"strings"
)

type ConfigRb struct {
	ClientKey     string
	ChefServerUrl string
	NodeName      string
}

type clientFunc func(s []string, path string, m *ConfigRb) error

var clientRegistry map[string]clientFunc

func init() {
	clientRegistry = make(map[string]clientFunc, 2)
	clientRegistry["client_key"] = configKeyParser
	clientRegistry["chef_server_url"] = configServerParser
	clientRegistry["node_name"] = configNodeNameParser

}
func NewClientRb(data, path string) (c ConfigRb, err error) {
	linesData := strings.Split(data, "\n")
	if len(linesData) < 3 {
		return c, errors.New("not much info")
	}
	for _, i := range linesData {
		key, value := getKeyValue(strings.TrimSpace(i))
		if fn, ok := clientRegistry[key]; ok {
			err = fn(value, path, &c)
			if err != nil {
				return
			}
		}
	}
	return c, err
}
func configKeyParser(s []string, path string, c *ConfigRb) error {
	str := StringParserForMeta(s)
	data := strings.Split(str, "/")
	size := len(data)
	if size > 0 {
		keyPath := filepath.Join(path, data[size-1])
		keyData, err := ioutil.ReadFile(keyPath)
		if err != nil {
			return err
		}
		c.ClientKey = string(keyData)
	}
	return nil
}
func configServerParser(s []string, path string, c *ConfigRb) error {
	c.ChefServerUrl = StringParserForMeta(s)
	return nil
}
func configNodeNameParser(s []string, path string, c *ConfigRb) error {
	c.NodeName = StringParserForMeta(s)
	return nil
}
