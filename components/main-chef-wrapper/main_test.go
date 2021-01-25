//
// Copyright 2019 Chef Software, Inc.
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

package main

import (
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
)

func Test_validateRolloutSetup(t *testing.T) {

	os.Setenv("CHEF_AC_SERVER_URL", "http://testhost")
	os.Setenv("CHEF_AC_SERVER_USER", "testuser")
	os.Setenv("CHEF_AC_AUTOMATE_URL", "http://testhost2")
	os.Setenv("CHEF_AC_AUTOMATE_TOKEN", "xyz123455677709u0")
	got := validateRolloutSetup()
	assert.Equal(t, got, true)
}

func Test_validateRolloutSetup_Invalid(t *testing.T) {

	os.Setenv("CHEF_AC_SERVER_URL", "http://testhost")
	os.Setenv("CHEF_AC_SERVER_USER", "testuser")
	os.Setenv("CHEF_AC_AUTOMATE_TOKEN", "xyz123455677709u0")
	got := validateRolloutSetup()
	assert.Equal(t, got, false)
}

func Test_getAction(t *testing.T) {
	
	cmd := getAction("push")
	assert.Equal(t, cmd, "push")
	cmd = getAction("report")
	assert.Equal(t, cmd, "report")
	cmd = getAction("capture")
	assert.Equal(t, cmd, "capture")

	os.Setenv("CHEF_AC_ROLLOUT_ENABLED", "true")
	cmd = getAction("push")
	assert.Equal(t, cmd, "none")

	os.Setenv("CHEF_AC_SERVER_URL", "http://testhost")
	cmd = getAction("push")
	assert.Equal(t, cmd, "none")
	
	os.Setenv("CHEF_AC_SERVER_USER", "testuser")
	os.Setenv("CHEF_AC_AUTOMATE_URL", "http://testhost2")
	os.Setenv("CHEF_AC_AUTOMATE_TOKEN", "xyz123455677709u0")
	cmd = getAction("push")
	assert.Equal(t, cmd, "policy-rollout")

}

