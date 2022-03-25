package supermarket

import (
	"errors"
	"fmt"
	"net/http"

	"github.com/go-chef/chef"
)

func UnShareCookbook(cookbook, superMarketSite, nodeName, key string) error {
	var chefConfig chef.Config
	chefConfig.BaseURL = superMarketSite
	chefConfig.Key = key
	chefConfig.Name = nodeName

	client, err := chef.NewClient(&chefConfig)
	if err != nil {
		fmt.Println(err)
	}
	req, err := client.NewRequest("DELETE", chefConfig.BaseURL+"/api/v1/cookbooks/starter", nil)
	if err != nil {
		fmt.Println(err)
	}
	var v interface{}
	resp, err := client.Do(req, v)
	if err != nil || resp.StatusCode == http.StatusForbidden {
		return errors.New("does not allow to unshare cookbook")
	}
	return nil
}
