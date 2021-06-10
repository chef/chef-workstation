
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

package lib
import (
"encoding/json"
"testing"
"github.com/stretchr/testify/assert"
)

func TestInputKey(t *testing.T) {
	var jsonBlob = []byte(`{"foo": {"bar": {"baz": 1}}}`)
	var v interface{}
	if err := json.Unmarshal(jsonBlob, &v); err != nil {
		t.Fatal(err)
	}
	success, err := Dig(v, "foo", "bar", "baz")
	assert.Equal(t, float64(1), success, "foo.bar.baz should be 1")
	assert.Nil(t, err)

	failure, err := Dig(v, "foo", "qux", "quux")
	assert.Nil(t, failure)
	assert.NotNil(t, err)
}
