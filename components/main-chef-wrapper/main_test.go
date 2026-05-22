//
// Copyright © 2021 Progress Software Corporation and/or its subsidiaries or affiliates. All Rights Reserved.
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
	"bytes"
	"fmt"
	"github.com/chef/chef-workstation/components/main-chef-wrapper/cmd"
	"github.com/spf13/cobra"
	"github.com/stretchr/testify/assert"
	"io/ioutil"
	"os"
	"path/filepath"
	"testing"
)

func NewRootCmd(in string) *cobra.Command {
	return &cobra.Command{
		Use:           "chef",
		Short:         "chef",
		SilenceErrors: true,
		RunE: func(cmd *cobra.Command, args []string) error {
			fmt.Fprintf(cmd.OutOrStdout(), in)
			return nil
		},
	}
}

func Test_ExecuteFunction(t *testing.T) {
	cmd := NewRootCmd("test")
	b := bytes.NewBufferString("")
	cmd.SetOut(b)
	cmd.Execute()
	out, err := ioutil.ReadAll(b)
	if err != nil {
		t.Fatal(err)
	}
	if string(out) != "test" {
		t.Fatalf("expected \"%s\" got \"%s\"", "test", string(out))
	}
}

func Test_ValidateRolloutSetup(t *testing.T) {

	os.Setenv("CHEF_AC_SERVER_URL", "http://testhost")
	os.Setenv("CHEF_AC_SERVER_USER", "testuser")
	os.Setenv("CHEF_AC_AUTOMATE_URL", "http://testhost2")
	os.Setenv("CHEF_AC_AUTOMATE_TOKEN", "test-token-not-secret")
	got := cmd.ValidateRolloutSetup()
	assert.Equal(t, got, true)
}

func TestLicenseFlagPathUsesChefSubdir(t *testing.T) {
	home := filepath.Join("tmp", "home")
	got := licenseFlagPath(home)
	want := filepath.Join(home, ".chef", licenseFlagFilename)

	if got != want {
		t.Fatalf("expected %q, got %q", want, got)
	}
}

func TestEnableLicenseFlagWritesPrivateMarker(t *testing.T) {
	home := t.TempDir()

	if err := enableLicenseFlag(home); err != nil {
		t.Fatalf("enableLicenseFlag failed: %v", err)
	}

	flagPath := licenseFlagPath(home)
	content, err := os.ReadFile(flagPath)
	if err != nil {
		t.Fatalf("failed to read marker file: %v", err)
	}
	if string(content) != "true" {
		t.Fatalf("expected marker content %q, got %q", "true", string(content))
	}

	fileInfo, err := os.Stat(flagPath)
	if err != nil {
		t.Fatalf("failed to stat marker file: %v", err)
	}
	if fileInfo.Mode().Perm()&0o077 != 0 {
		t.Fatalf("expected marker to be private (0600-style), got mode %o", fileInfo.Mode().Perm())
	}

	dirInfo, err := os.Stat(filepath.Join(home, ".chef"))
	if err != nil {
		t.Fatalf("failed to stat .chef dir: %v", err)
	}
	if dirInfo.Mode().Perm()&0o077 != 0 {
		t.Fatalf("expected .chef dir to be private (0700-style), got mode %o", dirInfo.Mode().Perm())
	}
}

//******commenting out  code added by @shafique for time being (test of policy rollout)*********

//func Test_ValidateRolloutSetup_Invalid(t *testing.T) {
//
//	// No var is set
//	got := cmd.ValidateRolloutSetup()
//	assert.Equal(t, got, false)
//
//	// all are set except CHEF_AC_SERVER_URL
//	os.Setenv("CHEF_AC_SERVER_USER", "testuser")
//	os.Setenv("CHEF_AC_AUTOMATE_URL", "http://testhost2")
//	os.Setenv("CHEF_AC_AUTOMATE_TOKEN", "test-token-not-secret")
//	got = cmd.ValidateRolloutSetup()
//	assert.Equal(t, got, false)
//
//	// all are set except CHEF_AC_SERVER_USER
//	os.Setenv("CHEF_AC_SERVER_URL", "http://testhost")
//	os.Unsetenv("CHEF_AC_SERVER_USER")
//	got = cmd.ValidateRolloutSetup()
//	assert.Equal(t, got, false)
//
//	// all are set except CHEF_AC_AUTOMATE_URL
//	os.Setenv("CHEF_AC_SERVER_USER", "testuser")
//	os.Unsetenv("CHEF_AC_AUTOMATE_URL")
//	got =cmd.ValidateRolloutSetup()
//	assert.Equal(t, got, false)
//
//	// all are set except CHEF_AC_AUTOMATE_TOKEN
//	os.Setenv("CHEF_AC_AUTOMATE_URL", "http://testhost2")
//	os.Unsetenv("CHEF_AC_AUTOMATE_TOKEN")
//	got = cmd.ValidateRolloutSetup()
//	assert.Equal(t, got, false)
//
//}

//func Test_getAction(t *testing.T) {
//
//	cmd := getAction("push")
//	assert.Equal(t, cmd, "push")
//	cmd = getAction("report")
//	assert.Equal(t, cmd, "report")
//	cmd = getAction("capture")
//	assert.Equal(t, cmd, "capture")
//
//	os.Setenv("CHEF_AC_ROLLOUT_ENABLED", "true")
//	cmd = getAction("push")
//	assert.Equal(t, cmd, "none")
//
//	os.Setenv("CHEF_AC_SERVER_URL", "http://testhost")
//	cmd = getAction("push")
//	assert.Equal(t, cmd, "none")
//
//	os.Setenv("CHEF_AC_SERVER_USER", "testuser")
//	os.Setenv("CHEF_AC_AUTOMATE_URL", "http://testhost2")
//	os.Setenv("CHEF_AC_AUTOMATE_TOKEN", "test-token-not-secret")
//	cmd = getAction("push")
//	assert.Equal(t, cmd, "policy-rollout")
//
//}
