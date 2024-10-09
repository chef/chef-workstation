package api

import (
	"strings"

	config "github.com/chef/chef-licensing/components/go/pkg/config"
)

type LicenseDetail struct {
	LicenseKey   string  `json:"licenseKey"`
	SerialNumber string  `json:"serialNumber"`
	LicenseType  string  `json:"licenseType"`
	Name         string  `json:"name"`
	Start        string  `json:"start"`
	End          string  `json:"end"`
	Status       string  `json:"status"`
	Limits       []Limit `json:"limits"`
}

type Limit struct {
	Software string `json:"software"`
	ID       string `json:"id"`
	Amount   int    `json:"amount"`
	Measure  string `json:"measure"`
	Used     int    `json:"used"`
	Status   string `json:"status"`
}

type Asset struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	Entitled bool   `json:"entitled"`
	From     []struct {
		LicenseKey string `json:"license"`
		Status     string `json:"status"`
	} `json:"from"`
}

type LicenseDescribe struct {
	Licenses  []LicenseDetail `json:"license"`
	Softwares []Asset         `json:"Software"`
	Features  []Asset         `json:"Features"`
	Assets    interface{}     `json:"Assets"`
	Services  interface{}     `json:"Services"`
}

type describeResponse struct {
	Data       LicenseDescribe `json:"data"`
	Message    string          `json:"message"`
	StatusCode int             `json:"status"`
}

func (c APIClient) GetLicenseDescribe(keys []string) (*LicenseDescribe, error) {
	params := map[string]string{
		"licenseId":     strings.Join(keys, ","),
		"entitlementId": config.GetConfig().EntitlementID,
	}

	resp, err := c.doGETRequest("desc", params)
	if err != nil {
		return nil, err
	}

	var data describeResponse
	c.decodeJSON(resp, &data)

	return &data.Data, nil
}
