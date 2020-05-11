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

package featflag

// looks up for a registered feature with either a matching key,
// or environment variable name
func Lookup(feature string) (*Feature, bool) {
	for _, feat := range featureFlags {
		if feat.configKey == feature {
			return &feat, true
		}
		if feat.envName == feature {
			return &feat, true
		}
	}
	return nil, false
}

// returns a registered feature with the matching key
func GetFromKey(key string) (*Feature, bool) {
	for _, feat := range featureFlags {
		if feat.configKey == key {
			return &feat, true
		}
	}
	return nil, false
}

// returns a registered feature with the matching env variable name
func GetFromEnv(name string) (*Feature, bool) {
	for _, feat := range featureFlags {
		if feat.envName == name {
			return &feat, true
		}
	}
	return nil, false
}
