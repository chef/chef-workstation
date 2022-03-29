package supermarket

import (
	"fmt"
	"strings"

	"github.com/chef/go-chef-cli/core"
	"github.com/go-chef/chef"
)

func ShowCookBook(cookbook, supermarketSite string, ui core.UI, config core.Config, version string) {
	client, err := chef.NewClientWithOutConfig(supermarketSite)
	if err != nil {
		ui.Fatal(err.Error())
	}
	uri := fmt.Sprintf("%s/api/v1/cookbooks/%s", supermarketSite, cookbook)
	if len(version) > 1 {
		version = strings.ReplaceAll(version, ".", "_")
		uri = fmt.Sprintf("%s/api/v1/cookbooks/%s/versions/%s", supermarketSite, cookbook, version)
	}
	var response interface{}
	err = client.MagicRequestResponseDecoderWithOutAuth(uri, "GET", nil, &response)
	if err != nil {
		ui.Fatal(err.Error())
	}

	ui.Output(config, response)

}
