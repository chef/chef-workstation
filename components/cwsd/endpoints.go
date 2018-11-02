package main

import (
	"encoding/json"
	"net/http"

	"github.com/gorilla/mux"
	"github.com/sirupsen/logrus"
	"github.com/spf13/viper"
)

type Endpoints struct {
	log    *logrus.Logger
	config *viper.Viper
	router *mux.Router
}

// TODO not viper, wrap it in a configservice (or module). This
// module just handles encoding/decoding and routing to the right backend.
// TODO rename this module - server/endpoints/config.go?
func InitEndpoints(log *logrus.Logger, config *viper.Viper, router *mux.Router) {
	ep := Endpoints{log: log, config: config, router: router}
	router.HandleFunc("/config/{key}", ep.GetConfigValue).Methods("GET")
	router.HandleFunc("/config/{key}", ep.SetConfigValue).Methods("PUT")
}

func (e *Endpoints) SetConfigValue(w http.ResponseWriter, req *http.Request) {
	var i interface{}
	params := mux.Vars(req)
	key := params["key"]
	err := json.NewDecoder(req.Body).Decode(&i)
	if err != nil {
		e.log.Error(err)
	}
	m := i.(map[string]interface{})
	// Lots of assumptions here around data - we'll wnat to validate, and possibly
	// find a way to map this to a struct.  It's a bit challenging because the value data type
	// is very variable. We could probably refer to it as interface{} in a struct, but that won't
	// really buy us anything over this.
	value := m["value"]
	e.config.Set(key, value)

	// TODO - not shippable, this loses comments and original formatting in config.
	e.config.WriteConfig()
}

func (e *Endpoints) GetConfigValue(w http.ResponseWriter, req *http.Request) {
	// e.config.Get(key)
	// params := mux.Vars(req)

	params := mux.Vars(req)
	key := params["key"]
	value := e.config.Get(key)
	e.log.Info("Value", value)
	resp := map[string]interface{}{
		"key":   key,
		"value": value,
	}
	// TODO: validation - something like this may be our best bet - key-specific
	//	typecasting (outbound) and  validation (inbound):

	// switch key {
	// case "telemetry.enable":
	// case string:
	//   fmt.Println(key, "is string", vv)
	// case bool:
	//   fmt.Println(key, "is bool", vv)
	// case float64:
	//   fmt.Println(key, "is float64", vv)
	// case {}interface{}: // nested hash
	// case []interface{}: // array - such as for cookbook_paths...
	// }
	// switch vv := value.(type) {
	json.NewEncoder(w).Encode(resp)
}
