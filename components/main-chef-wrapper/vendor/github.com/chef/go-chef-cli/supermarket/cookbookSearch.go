package supermarket

import (
	"fmt"

	"github.com/chef/go-chef-cli/core"
	"github.com/go-chef/chef"
)

type CookbookSearch struct {
	SearchArtifact
}

// String implements the Stringer Interface for the SearchArtifact
func (cs CookbookSearch) String() string {
	return fmt.Sprintf("%s/api/v1/search?q=%s&rows=%d&start=%d", cs.Url, cs.Query, cs.Rows, cs.Start)
}

// Search will search for given term on supermarket site
func (cs CookbookSearch) Search(ui core.UI, config core.Config) {
	client, err := chef.NewClientWithOutConfig(cs.Url)
	if err != nil {
		ui.Fatal(err.Error())
	}
	var response cookBookResponse
	err = client.MagicRequestResponseDecoderWithOutAuth(cs.String(), "GET", nil, &response)
	if err != nil {
		ui.Fatal(err.Error())
	}

	result := make(map[string]interface{}, len(response.Items))
	for _, i := range response.Items {
		result[i.Name] = i
	}
	ui.Output(config, result)
	newStart := cs.Start + searchItemsCount
	if newStart < response.Total && len(result) == searchItemsCount {
		cs.Start = newStart
		cs.Search(ui, config)
	}
}

type cookbook struct {
	Name        string `json:"cookbook_name" yaml:"cookbook_name"`
	Maintainer  string `json:"cookbook_maintainer" yaml:"cookbook_maintainer"`
	Description string `json:"cookbook_description" yaml:"cookbook_description"`
	Cookbook    string `json:"cookbook" yaml:"cookbook"`
}
type cookBookResponse struct {
	Start int `json:"start"`
	Total int `json:"total"`
	Items []cookbook
}
