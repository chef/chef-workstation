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
// LIMITATIONS UNDER THE LICENSE.
//

package cmd

import (
	"errors"
	"fmt"
	"net/url"
	"os"
	"strings"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

var pushCmd = &cobra.Command{
	Use:   "push POLICY_GROUP [ POLICYFILE ]",
	Short: "Push a local Policyfile lock to a policy group on the %s",
	Long: `
Upload an existing Policyfile.lock.json to a %s, along
with all the cookbooks contained in the Policy lock. The Policy lock is applied
to a specific POLICY_GROUP, which is a set of nodes that share the same
run_list and cookbooks.

See the policyfile documentation for more information:

https://docs.chef.io/policyfile/
`,
	DisableFlagParsing: true,
	FParseErrWhitelist: cobra.FParseErrWhitelist{UnknownFlags: true},
	RunE: func(cmd *cobra.Command, args []string) error {
		allArgs := os.Args[1:]
		if isRollOutEnabled() {
			emitCommandObservation("push_rollout_validation", "", nil, "start", nil)
			if !ValidateRolloutSetup() { // roll-out is enabled but setup not complete, we don't do anything
				emitCommandObservation("push_rollout_validation", "", nil, "error", errors.New("required rollout environment variables are not set"))
				return errors.New("Policy roll-out is enabled but required variables are not set")
			}
			emitCommandObservation("push_rollout_validation", "", nil, "success", nil)
			err := passThroughWithObservability("push_workstation", dist.WorkstationExec, allArgs)
			if err != nil {
				return err
			}
			serverURL := strings.TrimSpace(os.Getenv("CHEF_AC_SERVER_URL"))
			serverUser := strings.TrimSpace(os.Getenv("CHEF_AC_SERVER_USER"))
			allArgs := []string{"report-new-rollout", "-g", allArgs[1], "-l", allArgs[2],
				"-s", serverURL, "-u", serverUser}
			return passThroughWithObservability("push_rollout_report", dist.AutomateCollectExec, allArgs)
		}
		return passThroughWithObservability("push", dist.WorkstationExec, os.Args[1:])
	},
}

func init() {
	pushCmd.Short = fmt.Sprintf(pushCmd.Short, dist.ServerProduct)
	pushCmd.Long = fmt.Sprintf(pushCmd.Long, dist.ServerProduct)
	RootCmd.AddCommand(pushCmd)
}

func isRollOutEnabled() bool {
	// user wants to do policy push + roll out
	if os.Getenv("CHEF_AC_ROLLOUT_ENABLED") != "" {
		return true
	}
	return false
}

func ValidateRolloutSetup() bool {
	serverURL := strings.TrimSpace(os.Getenv("CHEF_AC_SERVER_URL"))
	if serverURL == "" {
		fmt.Fprintln(os.Stderr, "ERROR:", "CHEF_AC_SERVER_URL environment variable must be set for rollout reporting")
		return false
	}
	if !validateHTTPURL("CHEF_AC_SERVER_URL", serverURL) {
		return false
	}

	serverUser := strings.TrimSpace(os.Getenv("CHEF_AC_SERVER_USER"))
	if serverUser == "" {
		fmt.Fprintln(os.Stderr, "ERROR:", "CHEF_AC_SERVER_USER environment variable must be set for rollout reporting")
		return false
	}
	if strings.ContainsAny(serverUser, "\r\n") {
		fmt.Fprintln(os.Stderr, "ERROR:", "CHEF_AC_SERVER_USER must not contain newline characters")
		return false
	}

	automateURL := strings.TrimSpace(os.Getenv("CHEF_AC_AUTOMATE_URL"))
	if automateURL == "" {
		fmt.Fprintln(os.Stderr, "ERROR:", "CHEF_AC_AUTOMATE_URL environment variable must be set for rollout reporting")
		return false
	}
	if !validateHTTPURL("CHEF_AC_AUTOMATE_URL", automateURL) {
		return false
	}

	automateToken := strings.TrimSpace(os.Getenv("CHEF_AC_AUTOMATE_TOKEN"))
	if automateToken == "" {
		fmt.Fprintln(os.Stderr, "ERROR:", "CHEF_AC_AUTOMATE_TOKEN environment variable must be set for rollout reporting")
		return false
	}
	if strings.ContainsAny(automateToken, "\r\n") {
		fmt.Fprintln(os.Stderr, "ERROR:", "CHEF_AC_AUTOMATE_TOKEN must not contain newline characters")
		return false
	}

	return true
}

func validateHTTPURL(varName, value string) bool {
	u, err := url.Parse(value)
	if err != nil || u.Scheme == "" || u.Host == "" {
		fmt.Fprintf(os.Stderr, "ERROR: %s must be a valid absolute URL\n", varName)
		return false
	}

	if u.Scheme != "http" && u.Scheme != "https" {
		fmt.Fprintf(os.Stderr, "ERROR: %s must use http or https\n", varName)
		return false
	}

	return true
}
