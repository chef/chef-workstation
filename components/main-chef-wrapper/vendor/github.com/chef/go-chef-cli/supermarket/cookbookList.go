package supermarket

import (
	"fmt"
	"sort"

	"github.com/chef/go-chef-cli/core"
	"github.com/go-chef/chef"
)

func ListCookBook(supermarketSite, sortBy, user, withUri string, ui core.UI, config core.Config) {
	client, err := chef.NewClientWithOutConfig(supermarketSite)
	if err != nil {
		ui.Fatal(err.Error())
	}
	result := make(map[string]string, 200)
	err = getCookbookList(client, 0, searchItemsCount, supermarketSite, sortBy, user, result)
	if err != nil && len(result) < 1 {
		ui.Fatal(err.Error())
	}
	if len(withUri) > 0 {
		ui.Output(config, result)
	} else {
		var data []string
		for key := range result {
			data = append(data, key)
		}
		sort.Strings(data)
		ui.Output(config, data)
	}
}

func getCookbookList(client *chef.Client, start, items int, supermarketSite, sortBy, user string, data map[string]string) error {
	uri := fmt.Sprintf("%s/api/v1/cookbooks?items=%d&start=%d", supermarketSite, items, start)
	if len(sortBy) > 1 {
		uri = uri + "&order=" + sortBy
	}
	if len(user) > 1 {
		uri = uri + "&user=" + user
	}
	var response cookBookResponse
	err := client.MagicRequestResponseDecoderWithOutAuth(uri, "GET", nil, &response)
	if err != nil {
		return err
	}
	for _, i := range response.Items {
		data[i.Name] = i.Cookbook
	}
	newStart := start + items
	if items > len(response.Items) {
		newStart = start + len(response.Items)
	}
	if newStart < response.Total {
		return getCookbookList(client, newStart, items, supermarketSite, sortBy, user, data)
	}
	return err
}
