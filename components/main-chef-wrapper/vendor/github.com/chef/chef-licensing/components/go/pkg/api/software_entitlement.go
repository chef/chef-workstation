package api

type entitlementsResponse struct {
	Data       map[string][]Entitlement `json:"data"`
	StatusCode int                      `json:"status"`
}

type Entitlement struct {
	Name    string `json:"name"`
	ID      string `json:"id"`
	Measure string `json:"measure"`
	Limit   int    `json:"limit"`
	Grace   struct {
		Limit    int `json:"limit"`
		Duration int `json:"duration"`
	} `json:"grace"`
	Period struct {
		Start string `json:"start"`
		End   string `json:"end"`
	} `json:"period"`
}

func (c APIClient) GetAllEntitlementsByLisenceID(keys []string) (*map[string][]Entitlement, error) {
	params := struct {
		Keys []string `json:"licenseIds"`
	}{
		Keys: keys,
	}

	resp, err := c.doPOSTRequest("entitlements", params)
	if err != nil {
		return nil, err
	}

	var data entitlementsResponse
	c.decodeJSON(resp, &data)
	return &data.Data, nil
}
