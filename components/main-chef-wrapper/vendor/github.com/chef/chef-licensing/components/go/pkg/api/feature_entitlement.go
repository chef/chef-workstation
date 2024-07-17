package api

import (
	"fmt"
	"net/http"
)

type FeatureEntitlement struct {
	Entitled   bool            `json:"entitled"`
	EntitledBy map[string]bool `json:"entitledBy"`
}

type featureResponse struct {
	Data       FeatureEntitlement `json:"data"`
	StatusCode int                `json:"status"`
}

func (c APIClient) GetFeatureByName(featureName string, keys []string) (*FeatureEntitlement, error) {
	params := struct {
		Keys        []string `json:"licenseIds"`
		FeatureName string   `json:"featureName"`
	}{
		Keys:        keys,
		FeatureName: featureName,
	}

	resp, err := c.doPOSTRequest("featurebyname", params)
	if err != nil {
		return nil, err
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("received non-200 response: %d", resp.StatusCode)
	}

	var data featureResponse
	c.decodeJSON(resp, &data)
	return &data.Data, nil
}

func (c APIClient) GetFeatureByGUID(featureID string, keys []string) (*FeatureEntitlement, error) {
	params := struct {
		Keys      []string `json:"licenseIds"`
		FeatureID string   `json:"featureGuid"`
	}{
		Keys:      keys,
		FeatureID: featureID,
	}

	resp, err := c.doPOSTRequest("featurebyid", params)
	if err != nil {
		return nil, err
	}
	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("received non-200 response: %d", resp.StatusCode)
	}

	var data featureResponse
	c.decodeJSON(resp, &data)
	return &data.Data, nil
}
