package api

import (
	"errors"
	"net/http"
)

type listLicenseResponse struct {
	Data       []string `json:"Data"`
	Message    string   `json:"message"`
	StatusCode int      `json:"status_code"`
}

func (c APIClient) ListLicensesAPI() ([]string, error) {
	resp, err := c.doGETRequest("listLicenses", map[string]string{})
	if err != nil {
		return []string{}, err
	}
	if resp.StatusCode == http.StatusNotFound {
		return []string{}, errors.New("not found")
	}

	var out listLicenseResponse
	c.decodeJSON(resp, &out)
	return out.Data, nil
}
