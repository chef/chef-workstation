package cheflicensing

import (
	"github.com/chef/chef-licensing/components/go/pkg/api"
	keyfetcher "github.com/chef/chef-licensing/components/go/pkg/key_fetcher"
)

func FetchAndPersist() []string {
	return keyfetcher.FetchAndPersist()
}

func CheckSoftwareEntitlement() (bool, error) {
	keys := keyfetcher.FetchLicenseKeys()
	_, error := api.GetClient().GetLicenseClient(keys, true)
	if error == nil {
		return true, nil
	} else {
		return false, error
	}
}
