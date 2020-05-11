//
// Copyright 2019 Chef Software, Inc.
// Author: Salim Afiune <afiune@chef.io>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

// An abstraction to manipulate feature flags through environment variables
// and a configuration file. By default it contains global flags that can be
// used in multiple go packages.
//
// Global Feature Flag
//
// This example is using a predefined global feature flag:
//  if featflag.ChefFeatAnalyze.Enabled() {
//    // the analyze feature is enabled, act upon it
//  }
//
// Define A Local Feature Flag
//
// This example is defining a local feature flag:
//  chefFeatXYZ := featflag.New("CHEF_FEAT_XYZ", "xyz")
//  if chefFeatXYZ.Enabled() {
//    // the XYZ feature is enabled, act upon it
//  }
//
package featflag

import (
	"fmt"
	"os"
	"strings"

	"github.com/chef/go-libs/config"
)

type Feature struct {
	// the key associated to the feature flag defined inside the configuration file (config.toml)
	//
	// example of a config key:
	// ```toml
	// [features]
	// analyze = true
	// xyz = false
	// ```
	configKey string

	// the environment variable name associated to the feature flag
	//
	// example of environment variables:
	// CHEF_FEAT_ANALYZE=true
	// CHEF_FEAT_XYZ=true
	envName string
}

// global vs local feature flags
//
// when do I define a global feature flag?
// > when that flag is being used by multiple packages
//
// NOTE: all environment variables and config keys are unique
var (
	// this special feature will enable all features at once
	ChefFeatAll = Feature{
		configKey: "all",
		envName:   "CHEF_FEAT_ALL",
	}

	// enables the chef-analyze feature
	ChefFeatAnalyze = Feature{
		configKey: "analyze",
		envName:   "CHEF_FEAT_ANALYZE",
	}

	// a list of all feature flags, global and local
	featureFlags = []Feature{ChefFeatAll, ChefFeatAnalyze}

	// config instance to access feature keys
	cfg *config.Config
)

func init() {
	// if the user does not have a config.toml we still want them to
	// be able to use the environment based feature flag variables
	c, err := config.New()
	if err != nil {
		//debug("unable to load config: %s", err)
	}
	cfg = &c
}

// registers a new feature flag
//
// example of a new feature flag called 'foo':
// ```go
// chefFeatFoo := featflag.New("CHEF_FEAT_FOO", "foo")
// chefFeatFoo.Enabled()  // returns true if the feature flag is enabled
// ```
func New(envName, key string) Feature {
	// since all environment variables and config keys are unique,
	// to protect them, this function will verify if there is a
	// registered feature flag with any field, if so, it returns it
	if feat, exist := GetFromEnv(envName); exist {
		return *feat
	}
	if feat, exist := GetFromKey(key); exist {
		return *feat
	}

	// create a new feature
	feat := Feature{
		configKey: key,
		envName:   envName,
	}

	// register the new feature
	featureFlags = append(featureFlags, feat)

	return feat
}

// load a custom configuration instance,
// this config is used inside the func 'Enabled()'
func LoadConfig(c *config.Config) {
	cfg = c
}

func ListAll() string {
	list := make([]string, len(featureFlags))
	for i, feat := range featureFlags {
		list[i] = feat.String()
	}

	return strings.Join(list, " ")
}

func (feat *Feature) String() string {
	return fmt.Sprintf("(%s:%s)", feat.Key(), feat.Env())
}

func (feat *Feature) Env() string {
	return feat.envName
}

func (feat *Feature) Key() string {
	return feat.configKey
}

func (feat *Feature) Equals(xfeat *Feature) bool {
	if feat.String() == xfeat.String() {
		return true
	}

	return false
}

// a feature flag is enabled when:
//
// 1) either the configured environment variable is set to any value or,
// 2) the configured key is found and turned on inside the configuration file (config.toml)
//
// (the verification is done in that order)
func (feat *Feature) Enabled() bool {
	if !feat.Equals(&ChefFeatAll) && ChefFeatAll.Enabled() {
		return true
	}

	if os.Getenv(feat.Env()) != "" {
		// users can use any value to enable a feature flag
		//
		// example:
		// CHEF_FEAT_ALL=true
		// CHEF_FEAT_ALL=1
		return true
	}

	return feat.valueFromConfig()
}

// extract the value from the loaded configuration
func (feat *Feature) valueFromConfig() bool {
	if cfg == nil {
		return false
	}

	value, ok := cfg.Features[feat.Key()]
	if ok {
		return value
	}

	return false
}
