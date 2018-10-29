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
	err := json.NewDecoder(req.Body).Decode(&i)
	if err != nil {
		e.log.Error(err)
	}
	m := i.(map[string]interface{})
	params := mux.Vars(req)
	key := params["key"]
	value := m["value"]
	e.config.Set(key, value)

	e.config.WriteConfig()
	// TODO - would rather use typed struct, but the value is variable
	//        based on the key.   Borrwewd this bit from the 'json and go' page
	//for k, v := range m {
	// switch vv := value.(type) {
	// case string:
	//   fmt.Println(key, "is string", vv)
	// case bool:
	//   fmt.Println(key, "is bool", vv)
	// case float64:
	//   fmt.Println(key, "is float64", vv)
	// Disabling this - right now the config values we set cna't contain an array.
	// we don't have any of these
	// case []interface{}:
	//   fmt.Println(key, "is an array:"
	//   for i, u := range vv {
	//     fmt.Println(i, u)
	//   }

	// default:
	//   // TODO failure http response
	//   fmt.Println(key, "is of a type I don't know how to handle", vv)
	// }
	//}
}

// e.config.Set(key, value)
// e.config.WriteConfig()
// params := mux.Vars(req)
//
// w.WriteHeader(http.StatusOK)
//_ = json.NewDecoder(req.Body).Decode(&person)
// decode(interface{}) {
//   switch vv
//}

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
	// switch key {
	// case "telemetry.enable":
	// case string:
	//   fmt.Println(key, "is string", vv)
	// case bool:
	//   fmt.Println(key, "is bool", vv)
	// case float64:
	//   fmt.Println(key, "is float64", vv)
	// Disabling this - right now the config values we set cna't contain an array.
	// we don't have any of these
	// case []interface{}:
	// }
	// switch vv := value.(type) {
	json.NewEncoder(w).Encode(resp)
}
