package api

import (
	"encoding/json"
	"errors"
	"io"
	"log"
	"net/http"
	"strings"
	"time"

	config "github.com/chef/chef-licensing/components/go/pkg/config"
)

type apiResponse struct {
	Data       bool   `json:"data"`
	Message    string `json:"message"`
	StatusCode int    `json:"status_code"`
}

type clientAPIResponse struct {
	Data struct {
		Client LicenseClient `json:"client"`
	} `json:"data"`
	Message    string `json:"message"`
	StatusCode int    `json:"status_code"`
}

type LicenseClient struct {
	LicenseType string `json:"license"`
	Status      string `json:"status"`
	ChangesTo   string `json:"changesTo"`
	ChangesOn   string `json:"changesOn"`
	ChangesIn   int    `json:"changesIn"`
	Usage       string `json:"usage"`
	Used        int    `json:"used"`
	Limit       int    `json:"limit"`
	Measure     string `json:"measure"`
}

func (client LicenseClient) HaveGrace() bool {
	return client.Status == "Grace"
}

func (client LicenseClient) IsExpired() bool {
	return client.Status == "Expired"
}

func (client LicenseClient) IsExhausted() bool {
	return client.Status == "Exhausted"
}

func (client LicenseClient) IsActive() bool {
	return client.Status == "Active"
}

func (client LicenseClient) IsTrial() bool {
	return client.LicenseType == "trial"
}

func (client LicenseClient) IsFree() bool {
	return client.LicenseType == "free"
}

func (client LicenseClient) IsCommercial() bool {
	return client.LicenseType == "commercial"
}

func (client LicenseClient) LicenseExpirationDate() time.Time {
	expiresOn, err := time.Parse(time.RFC3339, client.ChangesOn)
	if err != nil {
		log.Fatal("Unknown expiration time received from the server: ", err)
	}

	return expiresOn
}

func (client LicenseClient) ExpirationInDays() int {
	expirationIn := int(time.Until(client.LicenseExpirationDate()).Hours() / 24)
	return expirationIn
}

func (client LicenseClient) IsAboutToExpire() (out bool) {
	expiration := client.ExpirationInDays()
	return client.Status == "Active" && client.ChangesTo == "Expired" && expiration >= 1 && expiration <= 7
}

func (client LicenseClient) IsExpiringOrExpired() bool {
	return client.HaveGrace() || client.IsExpired() || client.IsAboutToExpire()
}

func (c APIClient) GetLicenseClient(keys []string, options ...bool) (*LicenseClient, error) {
	params := map[string]string{
		"licenseId":     strings.Join(keys, ","),
		"entitlementId": config.GetConfig().EntitlementID,
	}

	resp, err := c.doGETRequest("client", params)
	if err != nil {
		return nil, err
	}

	var suppress bool
	if len(options) > 0 {
		suppress = options[0]
	}

	body := getResponseBody(resp)
	client, parseErr := parseClientResponse(body)
	if !suppress && parseErr != nil {
		log.Fatal(parseErr)
	}

	return client, parseErr
}

func parseClientResponse(body []byte) (*LicenseClient, error) {
	var resp clientAPIResponse
	err := json.Unmarshal(body, &resp)
	if err == nil && resp.Data.Client.LicenseType != "" {
		return &resp.Data.Client, nil
	}

	var invalidResp apiResponse
	err = json.Unmarshal(body, &invalidResp)
	if err == nil && !invalidResp.Data {
		return nil, errors.New(invalidResp.Message)

	}
	return nil, errors.New("Unable to parse the license client response")
}

func getResponseBody(resp *http.Response) []byte {
	defer resp.Body.Close()
	body, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Fatal(err)
	}

	return body
}
