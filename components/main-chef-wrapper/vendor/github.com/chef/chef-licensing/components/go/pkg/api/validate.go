package api

import (
	"errors"
	"log"
	"net/http"
)

type validateResponse struct {
	Data       bool   `json:"data"`
	Message    string `json:"message"`
	StatusCode int    `json:"status_code"`
}

func (v validateResponse) IsValid() bool {
	return v.Data
}

func (c APIClient) ValidateLicenseAPI(key string, options ...bool) (bool, error) {
	opts := map[string]string{
		"licenseId": key,
	}

	resp, err := c.doGETRequest("validate", opts)
	if err != nil {
		return false, err
	}

	var data validateResponse
	c.decodeJSON(resp, &data)
	var suppress bool
	if len(options) > 0 {
		suppress = options[0]
	}

	if resp.StatusCode != http.StatusOK {
		err = errors.New(data.Message)
		if !suppress {
			log.Fatal(err)
		}
	}

	return data.IsValid(), err
}
