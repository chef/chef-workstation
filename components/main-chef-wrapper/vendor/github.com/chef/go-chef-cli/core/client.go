package core
//
// import (
// 	"bytes"
// 	"crypto/sha1"
// 	"crypto/sha256"
// 	"crypto/tls"
// 	"encoding/base64"
// 	"encoding/json"
// 	"fmt"
// 	"io"
// 	"io/ioutil"
// 	"net/http"
// 	"os"
// 	"strings"
// 	"time"
// )
//
// type Client struct {
// 	client http.Client
// 	ui     UI
// }
//
// func NewClient() Client {
// 	netTransport := http.Transport{
// 		IdleConnTimeout:     30 * time.Second,
// 		TLSHandshakeTimeout: 20 * time.Second,
// 		TLSClientConfig:     &tls.Config{InsecureSkipVerify: true},
// 	}
// 	return Client{client: http.Client{
// 		Timeout:   60 * time.Second,
// 		Transport: &netTransport,
// 	},
// 		ui: UI{},
// 	}
// }
//
// // NewRequest returns a signed request  suitable for the chef server
// func (c *Client) NewRequest(method string, requestUrl string, body io.Reader) (*http.Request, error) {
//
// 	// NewRequest uses a new value object of body
// 	req, err := http.NewRequest(method, requestUrl, body)
// 	if err != nil {
// 		return nil, err
// 	}
//
// 	// parse and encode Querystring Values
// 	values := req.URL.Query()
// 	req.URL.RawQuery = values.Encode()
//
// 	myBody := &Body{body}
//
// 	if body != nil {
// 		// Detect Content-type
// 		req.Header.Set("Content-Type", myBody.ContentType())
// 	}
//
// 	return req, nil
// }
//
// // Body wraps io.Reader and adds methods for calculating hashes and detecting content
// type Body struct {
// 	io.Reader
// }
//
// // Buffer creates a  byte.Buffer copy from a io.Reader resets read on reader to 0,0
// func (body *Body) Buffer() *bytes.Buffer {
// 	var b bytes.Buffer
// 	if body.Reader == nil {
// 		return &b
// 	}
//
// 	b.ReadFrom(body.Reader)
// 	_, err := body.Reader.(io.Seeker).Seek(0, 0)
// 	if err != nil {
// 		fmt.Println(err)
// 		os.Exit(1)
// 	}
// 	return &b
// }
//
// // Hash calculates the body content hash
// func (body *Body) Hash() (h string) {
// 	b := body.Buffer()
// 	// empty buffs should return a empty string
// 	if b.Len() == 0 {
// 		h = HashStr("")
// 	}
// 	h = HashStr(b.String())
// 	return
// }
//
// // Hash256 calculates the body content hash
// func (body *Body) Hash256() (h string) {
// 	b := body.Buffer()
// 	// empty buffs should return a empty string
// 	if b.Len() == 0 {
// 		h = HashStr256("")
// 	}
// 	h = HashStr256(b.String())
// 	return
// }
//
// // ContentType returns the content-type string of Body as detected by http.DetectContentType()
// func (body *Body) ContentType() string {
// 	if json.Unmarshal(body.Buffer().Bytes(), &struct{}{}) == nil {
// 		return "application/json"
// 	}
// 	return http.DetectContentType(body.Buffer().Bytes())
// }
//
// // HashStr returns the base64 encoded SHA1 sum of the toHash string
// func HashStr(toHash string) string {
// 	h := sha1.New()
// 	io.WriteString(h, toHash)
// 	hashed := base64.StdEncoding.EncodeToString(h.Sum(nil))
// 	return hashed
// }
//
// // HashStr256 returns the base64 encoded SHA256 sum of the toHash string
// func HashStr256(toHash string) string {
// 	sum := sha256.Sum256([]byte(toHash))
// 	sumslice := sum[:]
// 	hashed := base64.StdEncoding.EncodeToString(sumslice)
// 	return hashed
// }
//
// /*
// An ErrorResponse reports one or more errors caused by an API request.
// Thanks to https://github.com/google/go-github
//
// The Response structure includes:
//         Status string
// 	StatusCode int
// */
// type ErrorResponse struct {
// 	Response *http.Response // HTTP response that caused this error
// 	// extracted error message converted to string if possible
// 	ErrorMsg string
// 	// json body raw byte stream from an error
// 	ErrorText []byte
// }
//
// type ErrorMsg struct {
// 	Error interface{} `json:"error"`
// }
//
// // Error implements the error interface method for ErrorResponse
// func (r *ErrorResponse) Error() string {
// 	return fmt.Sprintf("%v %v: %d",
// 		r.Response.Request.Method, r.Response.Request.URL,
// 		r.Response.StatusCode)
// }
//
// // extractErrorMsg makes a best faith effort to extract the error message text
// // from the response body returned from the Chef Server. Error messages are
// // typically formatted in a json body as {"error": ["msg"]}
// func extractErrorMsg(data []byte) string {
// 	errorMsg := &ErrorMsg{}
// 	json.Unmarshal(data, errorMsg)
// 	switch t := errorMsg.Error.(type) {
// 	case []interface{}:
// 		// Return the string as a byte stream
// 		var rmsg string
// 		for _, val := range t {
// 			switch inval := val.(type) {
// 			case string:
// 				rmsg = rmsg + inval + "\n"
// 			default:
// 				fmt.Printf("Unknown type  %+v data %+v\n", inval, val)
// 			}
// 			return strings.TrimSpace(rmsg)
// 		}
// 	default:
// 		fmt.Printf("Unknown type  %+v data %+v msg %+v\n", t, string(data), errorMsg.Error)
// 	}
// 	return ""
// }
//
// // CheckResponse receives a pointer to a http.Response and generates an Error via unmarshalling
// func CheckResponse(r *http.Response) error {
// 	if c := r.StatusCode; 200 <= c && c <= 299 {
// 		return nil
// 	}
// 	errorResponse := &ErrorResponse{Response: r}
// 	data, err := ioutil.ReadAll(r.Body)
// 	if err == nil && data != nil {
// 		json.Unmarshal(data, errorResponse)
// 		errorResponse.ErrorText = data
// 		errorResponse.ErrorMsg = extractErrorMsg(data)
// 	}
// 	return errorResponse
// }
//
// // Do is used either internally via our magic request shite or a user may use it
// func (c *Client) Do(req *http.Request, v interface{}) (*http.Response, error) {
// 	res, err := c.client.Do(req)
// 	if err != nil {
// 		return nil, err
// 	}
//
// 	// BUG(fujin) tightly coupled
// 	err = CheckResponse(res)
// 	if err != nil {
// 		return res, err
// 	}
//
// 	var resBuf bytes.Buffer
// 	resTee := io.TeeReader(res.Body, &resBuf)
//
// 	// no response interface specified
// 	if v == nil {
// 		return res, nil
// 	}
//
// 	// response interface, v, is an io writer
// 	if w, ok := v.(io.Writer); ok {
// 		_, err = io.Copy(w, resTee)
// 		return res, err
// 	}
//
// 	// response content-type specifies JSON encoded - decode it
// 	if hasJsonContentType(res) {
// 		err = json.NewDecoder(resTee).Decode(v)
//
// 		if err != nil {
// 			return res, err
// 		}
// 		return res, nil
// 	}
//
// 	// response interface, v, is type string and the content is plain text
// 	if _, ok := v.(*string); ok && hasTextContentType(res) {
// 		resbody, _ := ioutil.ReadAll(resTee)
// 		if err != nil {
// 			return res, err
// 		}
// 		out := string(resbody)
// 		*v.(*string) = out
// 		return res, nil
// 	}
//
// 	// Default response: Content-Type is not JSON. Assume v is a struct and decode the response as json
// 	err = json.NewDecoder(resTee).Decode(v)
// 	if err != nil {
// 		return res, err
// 	}
// 	return res, nil
// }
//
// func hasJsonContentType(res *http.Response) bool {
// 	contentType := res.Header.Get("Content-Type")
// 	return contentType == "application/json"
// }
//
// func hasTextContentType(res *http.Response) bool {
// 	contentType := res.Header.Get("Content-Type")
// 	return contentType == "text/plain"
// }
// func (c Client) MagicRequestResponseDecoder(url, method string, body io.Reader, v interface{}) error {
// 	req, err := c.NewRequest(method, url, body)
// 	if err != nil {
// 		return err
// 	}
//
// 	res, err := c.Do(req, v)
// 	if res != nil {
// 		defer res.Body.Close()
// 	}
// 	if err != nil {
// 		return err
// 	}
// 	return err
// }
