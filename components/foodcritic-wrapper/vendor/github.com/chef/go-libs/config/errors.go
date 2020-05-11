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

import "fmt"

//
// The intend of this file is to have a single place where we can easily
// visualize the list of all error messages that we present to users.
//

var (
	UserConfigTomlNotFoundErr = fmt.Sprintf(`
  %[1]s file not found. (default: $HOME/%[2]s/%[1]s)

  setup your local configuration file by following this documentation:
    - https://www.chef.sh/docs/reference/config/
`, DefaultChefWSUserConfigFile, WorkstationDir)

	UserConfigTomlMalformedErr = fmt.Sprintf(`
  unable to parse %s file.

  verify the format of the configuration file by following this documentation:
    - https://www.chef.sh/docs/reference/config/
`, DefaultChefWSUserConfigFile)

	AppConfigTomlNotFoundErr = fmt.Sprintf(`
  %[1]s file not found. (default: $HOME/%[2]s/%[1]s)

  verify that the %[3]s App is runnig on your local workstation.
`, DefaultChefWSUserConfigFile, WorkstationDir, WorkstationProduct)

	AppConfigTomlMalformedErr = fmt.Sprintf(`
  unable to parse %s file.

  there must be a problem with the %s App, verify the format of the configuration by following this documentation:
    - https://www.chef.sh/docs/reference/config/
`, DefaultChefWSAppConfigFile, WorkstationProduct)
)
