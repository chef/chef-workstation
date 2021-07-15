//
// Copyright (c) Chef Software, Inc.
// Copyright (c) 2020 Muneyuki Noguchi
// Based on the original by Muneyuki Noguchi at https://github.com/mnogu/go-dig
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
package lib

import (
	"fmt"
)

// Dig extracts the nested value specified by the keys from v
func Dig(v interface{}, keys ...interface{}) (interface{}, error) {
	n := len(keys)
	for i, key := range keys {
		inputKey, ok := key.(string)
		if ok {
			raw, ok := v.(map[string]interface{})
			if !ok {
				return nil, fmt.Errorf("%v isn't a map", v)
			}
			v, ok = raw[inputKey]
			if !ok {
				return nil, fmt.Errorf("key %v not found in %v", inputKey, v)
			}
			if i == n-1 {
				return v, nil
			}
			continue
		}
		return nil, fmt.Errorf("unsupported key type: %v", key)
	}
	return nil, fmt.Errorf("no key is given")
}
