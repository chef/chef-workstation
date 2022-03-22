package chef

import (
	"encoding/json"
	"errors"
	"fmt"
	"io/ioutil"
	"os"
	"path/filepath"
	"strings"
)

const metaRbName = "metadata.rb"
const metaJsonName = "metadata.json"

type metaFunc func(s []string, m *CookbookMeta) error

var metaRegistry map[string]metaFunc

// CookbookService  is the service for interacting with chef server cookbooks endpoint
type CookbookService struct {
	client *Client
}

// CookbookItem represents a object of cookbook file data
type CookbookItem struct {
	Url         string `json:"url,omitempty"`
	Path        string `json:"path,omitempty"`
	Name        string `json:"name,omitempty"`
	Checksum    string `json:"checksum,omitempty"`
	Specificity string `json:"specificity,omitempty"`
}

// CookbookListResult is the summary info returned by chef-api when listing
// http://docs.opscode.com/api_chef_server.html#cookbooks
type CookbookListResult map[string]CookbookVersions

// CookbookRecipesResult is the summary info returned by chef-api when listing
// http://docs.opscode.com/api_chef_server.html#cookbooks-recipes
type CookbookRecipesResult []string

// CookbookVersions is the data container returned from the chef server when listing all cookbooks
type CookbookVersions struct {
	Url      string            `json:"url,omitempty"`
	Versions []CookbookVersion `json:"versions,omitempty"`
}

// CookbookVersion is the data for a specific cookbook version
type CookbookVersion struct {
	Url     string `json:"url,omitempty"`
	Version string `json:"version,omitempty"`
}

// CookbookMeta represents a Golang version of cookbook metadata
type CookbookMeta struct {
	Name               string                 `json:"name,omitempty"`
	Version            string                 `json:"version,omitempty"`
	Description        string                 `json:"description,omitempty"`
	LongDescription    string                 `json:"long_description,omitempty"`
	Maintainer         string                 `json:"maintainer,omitempty"`
	MaintainerEmail    string                 `json:"maintainer_email,omitempty"`
	License            string                 `json:"license,omitempty"`
	Platforms          map[string]interface{} `json:"platforms,omitempty"`
	Depends            map[string]string      `json:"dependencies,omitempty"`
	Reccomends         map[string]string      `json:"recommendations,omitempty"`
	Suggests           map[string]string      `json:"suggestions,omitempty"`
	Conflicts          map[string]string      `json:"conflicting,omitempty"`
	Provides           map[string]interface{} `json:"providing,omitempty"`
	Replaces           map[string]string      `json:"replacing,omitempty"`
	Attributes         map[string]interface{} `json:"attributes,omitempty"` // this has a format as well that could be typed, but blargh https://github.com/lob/chef/blob/master/cookbooks/apache2/metadata.json
	Groupings          map[string]interface{} `json:"groupings,omitempty"`  // never actually seen this used.. looks like it should be map[string]map[string]string, but not sure http://docs.opscode.com/essentials_cookbook_metadata.html
	Recipes            map[string]string      `json:"recipes,omitempty"`
	SourceUrl          string                 `json:"source_url"`
	IssueUrl           string                 `json:"issues_url"`
	ChefVersion        string
	OhaiVersion        string
	Gems               []string `json:"gems"`
	EagerLoadLibraries bool     `json:"eager_load_libraries"`
	Privacy            bool     `json:"privacy"`
}

// CookbookAccess represents the permissions on a Cookbook
type CookbookAccess struct {
	Read   bool `json:"read,omitempty"`
	Create bool `json:"create,omitempty"`
	Grant  bool `json:"grant,omitempty"`
	Update bool `json:"update,omitempty"`
	Delete bool `json:"delete,omitempty"`
}

// Cookbook represents the native Go version of the deserialized api cookbook
type Cookbook struct {
	CookbookName string         `json:"cookbook_name"`
	Name         string         `json:"name"`
	Version      string         `json:"version,omitempty"`
	ChefType     string         `json:"chef_type,omitempty"`
	Frozen       bool           `json:"frozen?,omitempty"`
	JsonClass    string         `json:"json_class,omitempty"`
	Files        []CookbookItem `json:"files,omitempty"`
	Templates    []CookbookItem `json:"templates,omitempty"`
	Attributes   []CookbookItem `json:"attributes,omitempty"`
	Recipes      []CookbookItem `json:"recipes,omitempty"`
	Definitions  []CookbookItem `json:"definitions,omitempty"`
	Libraries    []CookbookItem `json:"libraries,omitempty"`
	Providers    []CookbookItem `json:"providers,omitempty"`
	Resources    []CookbookItem `json:"resources,omitempty"`
	RootFiles    []CookbookItem `json:"root_files,omitempty"`
	Metadata     CookbookMeta   `json:"metadata,omitempty"`
	Access       CookbookAccess `json:"access,omitempty"`
}

// String makes CookbookListResult implement the string result
func (c CookbookListResult) String() (out string) {
	for k, v := range c {
		out += fmt.Sprintf("%s => %s\n", k, v.Url)
		for _, i := range v.Versions {
			out += fmt.Sprintf(" * %s\n", i.Version)
		}
	}
	return out
}

// versionParams assembles a querystring for the chef api's  num_versions
// This is used to restrict the number of versions returned in the reponse
func versionParams(path, numVersions string) string {
	if numVersions == "0" {
		numVersions = "all"
	}

	// need to optionally add numVersion args to the request
	if len(numVersions) > 0 {
		path = fmt.Sprintf("%s?num_versions=%s", path, numVersions)
	}
	return path
}

// Get retruns a CookbookVersion for a specific cookbook
//  GET /cookbooks/name
func (c *CookbookService) Get(name string) (data CookbookVersion, err error) {
	path := fmt.Sprintf("cookbooks/%s", name)
	err = c.client.magicRequestDecoder("GET", path, nil, &data)
	return
}

// GetAvailable returns the versions of a coookbook available on a server
func (c *CookbookService) GetAvailableVersions(name, numVersions string) (data CookbookListResult, err error) {
	path := versionParams(fmt.Sprintf("cookbooks/%s", name), numVersions)
	err = c.client.magicRequestDecoder("GET", path, nil, &data)
	return
}

// GetVersion fetches a specific version of a cookbooks data from the server api
//   GET /cookbook/foo/1.2.3
//   GET /cookbook/foo/_latest
//   Chef API docs: https://docs.chef.io/api_chef_server.html#cookbooks-name-version
func (c *CookbookService) GetVersion(name, version string) (data Cookbook, err error) {
	url := fmt.Sprintf("cookbooks/%s/%s", name, version)
	err = c.client.magicRequestDecoder("GET", url, nil, &data)
	return
}

// ListVersions lists the cookbooks available on the server limited to numVersions
//   Chef API docs: https://docs.chef.io/api_chef_server.html#cookbooks-name
func (c *CookbookService) ListAvailableVersions(numVersions string) (data CookbookListResult, err error) {
	path := versionParams("cookbooks", numVersions)
	err = c.client.magicRequestDecoder("GET", path, nil, &data)
	return
}

// ListAllRecipes lists the names of all recipes in the most recent cookbook versions
//   Chef API docs: https://docs.chef.io/api_chef_server.html#cookbooks-recipes
func (c *CookbookService) ListAllRecipes() (data CookbookRecipesResult, err error) {
	path := "cookbooks/_recipes"
	err = c.client.magicRequestDecoder("GET", path, nil, &data)
	return
}

// List returns a CookbookListResult with the latest versions of cookbooks available on the server
func (c *CookbookService) List() (CookbookListResult, error) {
	return c.ListAvailableVersions("")
}

// DeleteVersion removes a version of a cook from a server
func (c *CookbookService) Delete(name, version string) (err error) {
	path := fmt.Sprintf("cookbooks/%s/%s", name, version)
	err = c.client.magicRequestDecoder("DELETE", path, nil, nil)
	return
}
func ReadMetaData(path string) (m CookbookMeta, err error) {
	fileName := filepath.Join(path, metaJsonName)
	jsonType := true
	if !isFileExists(fileName) {
		jsonType = false
		fileName = filepath.Join(path, metaRbName)

	}
	file, err := ioutil.ReadFile(fileName)
	if err != nil {
		fmt.Println(err.Error())
		os.Exit(1)
	}
	if jsonType {
		return NewMetaDataFromJson(file)
	} else {
		return NewMetaData(string(file))
	}

}
func trimQuotes(s string) string {
	if len(s) >= 2 {
		if c := s[len(s)-1]; s[0] == c && (c == '"' || c == '\'') {
			return s[1 : len(s)-1]
		}
	}
	return s
}
func getKeyValue(str string) (string, []string) {
	c := strings.Split(str, " ")
	if len(c) == 0 {
		return "", nil
	}
	return strings.TrimSpace(c[0]), c[1:]
}
func isFileExists(name string) bool {
	if _, err := os.Stat(name); errors.Is(err, os.ErrNotExist) {
		return false
	}
	return true
}

func clearWhiteSpace(s []string) (result []string) {
	for _, i := range s {
		if len(i) > 0 {
			result = append(result, i)
		}
	}
	return result
}

func NewMetaData(data string) (m CookbookMeta, err error) {
	linesData := strings.Split(data, "\n")
	if len(linesData) < 3 {
		return m, errors.New("not much info")
	}
	m.Depends = make(map[string]string, 1)
	m.Platforms = make(map[string]interface{}, 1)
	for _, i := range linesData {
		key, value := getKeyValue(strings.TrimSpace(i))
		if fn, ok := metaRegistry[key]; ok {
			err = fn(value, &m)
			if err != nil {
				return
			}
		}
	}
	return m, err
}

func NewMetaDataFromJson(data []byte) (m CookbookMeta, err error) {
	err = json.Unmarshal(data, &m)
	return m, err
}

func StringParserForMeta(s []string) string {
	str := strings.Join(s, " ")
	return trimQuotes(strings.TrimSpace(str))
}
func metaNameParser(s []string, m *CookbookMeta) error {
	m.Name = StringParserForMeta(s)
	return nil
}
func metaMaintainerParser(s []string, m *CookbookMeta) error {
	m.Maintainer = StringParserForMeta(s)
	return nil
}
func metaMaintainerMailParser(s []string, m *CookbookMeta) error {
	m.MaintainerEmail = StringParserForMeta(s)
	return nil
}
func metaLicenseParser(s []string, m *CookbookMeta) error {
	m.License = StringParserForMeta(s)
	return nil
}
func metaDescriptionParser(s []string, m *CookbookMeta) error {
	m.Description = StringParserForMeta(s)
	return nil
}
func metaLongDescriptionParser(s []string, m *CookbookMeta) error {
	m.LongDescription = StringParserForMeta(s)
	return nil
}
func metaIssueUrlParser(s []string, m *CookbookMeta) error {
	m.IssueUrl = StringParserForMeta(s)
	return nil
}
func metaSourceUrlParser(s []string, m *CookbookMeta) error {
	m.SourceUrl = StringParserForMeta(s)
	return nil
}
func metaGemParser(s []string, m *CookbookMeta) error {
	m.Gems = append(m.Gems, StringParserForMeta(s))
	return nil
}

func metaVersionParser(s []string, m *CookbookMeta) error {
	m.Version = StringParserForMeta(s)
	return nil
}
func metaOhaiVersionParser(s []string, m *CookbookMeta) error {
	m.OhaiVersion = StringParserForMeta(s)
	return nil
}
func metaChefVersionParser(s []string, m *CookbookMeta) error {
	m.ChefVersion = StringParserForMeta(s)
	return nil
}
func metaPrivacyParser(s []string, m *CookbookMeta) error {
	if s[0] == "true" {
		m.Privacy = true
	}
	return nil
}
func metaSupportsParser(s []string, m *CookbookMeta) error {
	s = clearWhiteSpace(s)
	switch len(s) {
	case 1:
		if s[0] != "os" {
			m.Platforms[strings.TrimSpace(s[0])] = ">= 0.0.0"
		}
	case 2:
		m.Platforms[strings.TrimSpace(s[0])] = s[1]
	case 3:
		v := trimQuotes(s[1] + " " + s[2])
		m.Platforms[strings.TrimSpace(s[0])] = v

	}
	if len(s) > 3 {
		return errors.New(`<<~OBSOLETED
		The dependency specification syntax you are using is no longer valid. You may not
		specify more than one version constraint for a particular cookbook.
			Consult https://docs.chef.io/config_rb_metadata/ for the updated syntax.`)
	}
	return nil
}
func metaDependsParser(s []string, m *CookbookMeta) error {
	s = clearWhiteSpace(s)
	switch len(s) {
	case 1:
		m.Depends[strings.TrimSpace(s[0])] = ">= 0.0.0"
	case 2:
		m.Depends[strings.TrimSpace(s[0])] = s[1]

	case 3:
		v := trimQuotes(s[1] + " " + s[2])
		m.Depends[strings.TrimSpace(s[0])] = v

	}
	if len(s) > 3 {
		return errors.New(`<<~OBSOLETED
		The dependency specification syntax you are using is no longer valid. You may not
		specify more than one version constraint for a particular cookbook.
			Consult https://docs.chef.io/config_rb_metadata/ for the updated syntax.`)
	}
	return nil
}

func metaSupportsRubyParser(s []string, m *CookbookMeta) error {
	if len(s) > 1 {
		for _, i := range s {
			switch i {
			case ").each":
				continue
			case "do":
				continue
			case "|os|":
				continue
			default:
				m.Platforms[strings.TrimSpace(s[0])] = ">= 0.0.0"
			}
		}
	}
	return nil
}
func init() {
	metaRegistry = make(map[string]metaFunc, 15)
	metaRegistry["name"] = metaNameParser
	metaRegistry["maintainer"] = metaMaintainerParser
	metaRegistry["maintainer_email"] = metaMaintainerMailParser
	metaRegistry["license"] = metaLicenseParser
	metaRegistry["description"] = metaDescriptionParser
	metaRegistry["long_description"] = metaLongDescriptionParser
	metaRegistry["source_url"] = metaSourceUrlParser
	metaRegistry["issues_url"] = metaIssueUrlParser
	metaRegistry["platforms"] = metaSupportsParser
	metaRegistry["supports"] = metaSupportsParser
	metaRegistry["%w("] = metaSupportsRubyParser
	metaRegistry["privacy"] = metaPrivacyParser
	metaRegistry["depends"] = metaDependsParser
	metaRegistry["version"] = metaVersionParser
	metaRegistry["chef_version"] = metaChefVersionParser
	metaRegistry["ohai_version"] = metaOhaiVersionParser
	metaRegistry["gem"] = metaGemParser

}
