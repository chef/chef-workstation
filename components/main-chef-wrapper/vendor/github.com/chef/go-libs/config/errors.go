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

//
// The intend of this file is to have a single place where we can easily
// visualize the list of all error messages that we present to users.
//

const (
	UserConfigTomlNotFoundErr = `
  ` + DefaultChefWSUserConfigFile + ` file not found. (default: $HOME/.chef-workstation/` + DefaultChefWSUserConfigFile + `)

  setup your local configuration file by following this documentation:
    - https://www.chef.sh/docs/reference/config/
`
	UserConfigTomlMalformedErr = `
  unable to parse ` + DefaultChefWSUserConfigFile + ` file.

  verify the format of the configuration file by following this documentation:
    - https://www.chef.sh/docs/reference/config/
`
	AppConfigTomlNotFoundErr = `
  ` + DefaultChefWSAppConfigFile + ` file not found. (default: $HOME/.chef-workstation/` + DefaultChefWSAppConfigFile + `)

  verify that the Chef Workstation App is runnig on your local workstation.
`
	AppConfigTomlMalformedErr = `
  unable to parse ` + DefaultChefWSAppConfigFile + ` file.

  there must be a problem with the Chef Workstation App, verify the format of the configuration by following this documentation:
    - https://www.chef.sh/docs/reference/config/
`
)
