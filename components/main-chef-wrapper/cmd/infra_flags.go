//
// Copyright 2020 Chef Software, Inc.
//
// Author: Marc A. Paradise <marc.paradise@gmail.com>
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

package cmd

import (
	"fmt"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

// TODO - this file copied shamelessly from chef-analyze/cmd/infra_flags.go
//        This may be something it makes sense to mvoe down into go-libs to avoid syncing
//        issues between main-chef-wrapper and chef-analyze. Leaving this for now, because it's
//        not something that changes frequently.

var infraFlags struct {
	credsFile     string
	clientName    string
	clientKey     string
	chefServerURL string
	profile       string
	noSSLverify   bool
}

// Adds common chef-infra flags to the given command
func AddInfraFlagsToCommand(cmd *cobra.Command) {

	// global report commands infraFlags
	cmd.PersistentFlags().StringVarP(
		&infraFlags.credsFile,
		// TODO - we inherit 'config', 'debug' from root, but we don't want config
		// and may not want debug

		// TODO - changed this to capital C for compat with otherwise-global
		// "--config/c".  Even in command where to do not wnat to show
		// some flags (like --config) we should not re-use their short-codes anywhere else.

		"credentials", "C", "",
		fmt.Sprintf("credentials file (default $HOME/%s/credentials)",
			dist.UserConfDir),
	)
	cmd.PersistentFlags().StringVarP(
		&infraFlags.clientName, "client-name", "n", "",
		fmt.Sprintf("%s API client name", dist.ServerProduct),
	)
	cmd.PersistentFlags().StringVarP(
		&infraFlags.clientKey, "client-key", "k", "",
		fmt.Sprintf("%s API client key", dist.ServerProduct),
	)
	cmd.PersistentFlags().StringVarP(
		&infraFlags.chefServerURL, "chef-server-url", "s", "",
		fmt.Sprintf("%s URL", dist.ServerProduct),
	)
	cmd.PersistentFlags().StringVarP(
		&infraFlags.profile,
		"profile", "p", "default",
		"profile to use from credentials file",
	)
	cmd.PersistentFlags().BoolVarP(
		&infraFlags.noSSLverify,
		"ssl-no-verify", "o", false,
		fmt.Sprintf("Do not verify SSL when connecting to %s (default: verify)",
			dist.ServerProduct),
	)
}
