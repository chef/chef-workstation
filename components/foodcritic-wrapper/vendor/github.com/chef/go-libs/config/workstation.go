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

package config

import (
	"os"
	"path/filepath"

	"github.com/pkg/errors"
)

const (
	DefaultChefWorkstationDirectory = WorkstationDir
	DefaultChefWSUserConfigFile     = "config.toml"
	DefaultChefWSAppConfigFile      = ".app-managed-config.toml"
)

// returns the ~/.chef-workstation directory
func ChefWorkstationDir() (string, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return "", errors.Wrap(err, "unable to detect home directory")
	}
	return filepath.Join(home, DefaultChefWorkstationDirectory), nil
}
