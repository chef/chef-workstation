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
	"os"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

var pushCmd = &cobra.Command{
	Use:   "push POLICY_GROUP [ POLICY_FILE ]",
	Short: "Push a local policyfile lock to a policy group on the %s",
	Long: `
Upload an existing Policyfile.lock.json to a %s, along
with all the cookbooks contained in the policy lock. The policy lock is applied
to a specific POLICY_GROUP, which is a set of nodes that share the same
run_list and cookbooks.

See the Policyfile documentation for more information:

https://docs.chef.io/policyfile/
`,
	FParseErrWhitelist: cobra.FParseErrWhitelist{UnknownFlags: true},
	RunE: func(cmd *cobra.Command, args []string) error {
		allArgs := os.Args[1:]
		if isRollOutEnabled() {
			if !validateRolloutSetup() { // roll-out is enabled but setup not complete, we don't do anything
				return errors.New("Policy roll-out is enabled but required variables are not set")
			}
			err := passThroughCommand(dist.WorkstationExec, "", allArgs)
			if err != nil {
				return err
			}
			allArgs := []string{"report-new-rollout", "-g", allArgs[1], "-l", allArgs[2],
				"-s", os.Getenv("CHEF_AC_SERVER_URL"), "-u", os.Getenv("CHEF_AC_SERVER_USER")}
			return passThroughCommand(dist.AutomateCollectExec, "", allArgs)
		}
		return passThroughCommand(dist.WorkstationExec, "", os.Args[1:])
	},
}

func init() {
	pushCmd.Short = fmt.Sprintf(pushCmd.Short, dist.ServerProduct)
	pushCmd.Long = fmt.Sprintf(pushCmd.Long, dist.ServerProduct)
	rootCmd.AddCommand(pushCmd)
}

func isRollOutEnabled() bool {
	// user wants to do policy push + roll out
	if os.Getenv("CHEF_AC_ROLLOUT_ENABLED") != "" {
		return true
	}
	return false
}

func validateRolloutSetup() bool {

	if os.Getenv("CHEF_AC_SERVER_URL") == "" {
		fmt.Fprintln(os.Stderr, "ERROR:", "CHEF_AC_SERVER_URL environment variable must be set for rollout reporting")
		return false
	}
	if os.Getenv("CHEF_AC_SERVER_USER") == "" {
		fmt.Fprintln(os.Stderr, "ERROR:", "CHEF_AC_SERVER_USER environment variable must be set for rollout reporting")
		return false
	}
	if os.Getenv("CHEF_AC_AUTOMATE_URL") == "" {
		fmt.Fprintln(os.Stderr, "ERROR:", "CHEF_AC_AUTOMATE_URL environment variable must be set for rollout reporting")
		return false
	}
	if os.Getenv("CHEF_AC_AUTOMATE_TOKEN") == "" {
		fmt.Fprintln(os.Stderr, "ERROR:", "CHEF_AC_AUTOMATE_TOKEN environment variable must be set for rollout reporting")
		return false
	}

	return true
}
