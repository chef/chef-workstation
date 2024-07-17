package api

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"net/http"
	"net/url"
	"sync"

	config "github.com/chef/chef-licensing/components/go/pkg/config"
	// licenseclient "github.com/progress-platform-services/chef-platform-license-management/public/client/license-management/license"
)

const (
	CLIENT_VERSION = "v1"
)

type APIClient struct {
	URL        string
	HTTPClient *http.Client
	Headers    map[string]string
}

var (
	apiClient *APIClient
	once      sync.Once
)

func (c *APIClient) BaseURL() string {
	baseUrl, err := url.Parse(fmt.Sprintf("%s/%s/", c.URL, CLIENT_VERSION))
	if err != nil {
		log.Fatal("Error parsing the provided URL: ", err)
	}
	return baseUrl.String()
}

// func NewAPIClient() licenseclient.LicenseClient {
// 	cfg := config.GetConfig()
// 	conf := pconfig.DefaultHttpConfig(cfg.LicenseServerURL)
// 	logger, err := plogger.NewLogger(plogger.LoggerConfig{LogLevel: "debug", LogToStdout: true})
// 	fmt.Println("Loggflaslfjalskfjlaksfjlkj")
// 	logger.Warn("Test log")
// 	if err != nil {
// 		log.Fatal("Unable to create a logger", err)
// 	}
// 	agent, err := pagent.NewAgent(conf, pagent.BasicClient, pauthtype.NoAuth{}, pcache.NewLocalCache(time.Second*60, time.Second*60), logger)
// 	if err != nil {
// 		log.Fatal("Unable to create the api client ", err)
// 	}
// 	return licenseclient.NewLicenseClient(conf, agent, nil, false, nil, nil, logger)
// }

func NewClient() *APIClient {
	cfg := config.GetConfig()

	apiClient = &APIClient{
		URL:        cfg.LicenseServerURL,
		HTTPClient: &http.Client{},
		Headers: map[string]string{
			"Content-Type": "application/json",
		},
	}
	return apiClient
}

func GetClient() *APIClient {
	once.Do(func() {
		apiClient = NewClient()
	})

	return apiClient
}

func (c *APIClient) SetHeader(key, value string) {
	c.Headers[key] = value
}

func (c *APIClient) doGETRequest(endpoint string, queryParams map[string]string) (*http.Response, error) {
	urlObj, err := url.Parse(endpoint)
	if err != nil {
		return nil, err
	}

	if queryParams != nil {
		q := urlObj.Query()
		for key, value := range queryParams {
			q.Add(key, value)
		}
		urlObj.RawQuery = q.Encode()
	}
	return c.doRequest("GET", urlObj.String(), nil)
}

func (c *APIClient) doPOSTRequest(endpoint string, body interface{}) (*http.Response, error) {
	var reqBody io.Reader
	var err error

	if body != nil {
		reqBody, err = c.encodeJSON(body)
		if err != nil {
			return nil, err
		}
	}
	return c.doRequest("POST", endpoint, reqBody)
}

func (c *APIClient) doRequest(method, endpoint string, body io.Reader) (*http.Response, error) {
	url := c.BaseURL() + endpoint
	req, err := http.NewRequest(method, url, body)
	if err != nil {
		return nil, err
	}

	for key, value := range c.Headers {
		req.Header.Set(key, value)
	}
	return c.HTTPClient.Do(req)
}

func (c *APIClient) decodeJSON(resp *http.Response, v interface{}) {
	defer resp.Body.Close()
	err := json.NewDecoder(resp.Body).Decode(v)
	if err != nil {
		log.Fatal("Failed to parse the response from the server:", err)
	}
}

func (c *APIClient) encodeJSON(v interface{}) (io.Reader, error) {
	buf := new(bytes.Buffer)
	err := json.NewEncoder(buf).Encode(v)
	if err != nil {
		return nil, err
	}

	return buf, nil
}
