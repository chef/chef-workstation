package licensing

import (
	"encoding/json"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
	"os"
)

type Response struct {
	Data       interface{} `json:"data"`
	Message    string      `json:"message"`
	StatusCode int         `json:"status_code"`
}

// ENDPOINTS CONSTANT
const (
	CLIENT = "v1/client"
)

func invokeGetAPI(opts map[string]string, URL string) {
	params := url.Values{}

	params.Add("licenseId", opts["licenseId"])
	params.Add("entitlementId", opts["entitlementId"])

	key, check := os.LookupEnv("CHEF_LICENSE_SERVER")
	if check {
		URL = key
	}
	res, err := http.Get(URL + "/" + CLIENT + "?" + params.Encode())
	if err != nil {
		log.Fatal(err.Error())
	}
	defer res.Body.Close()
	body, err := ioutil.ReadAll(res.Body)
	if err != nil {
		log.Fatal(err)
	}

	var response Response
	if err := json.Unmarshal(body, &response); err != nil { // Parse []byte to go struct pointer
		log.Println("Can not unmarshal JSON")
		log.Fatal(err)
	}
	if response.StatusCode != 200 {
		log.Fatal(response.Message)
	}
	// fmt.Println("response is---", PrettyPrint(response))
	if response.Data == false {
		log.Fatal("Error:", response.Message)
	}
}

// func PrettyPrint(i interface{}) string {
// 	s, _ := json.MarshalIndent(i, "", "\t")
// 	return string(s)
// }
