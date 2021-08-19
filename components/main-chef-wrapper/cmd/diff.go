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
	"fmt"
	"os"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

var (
	head      bool
	gitAction string
	pager     bool

	diffCmd = &cobra.Command{
		Use:                   "diff [POLICYFILE] [--head | --git GIT_REF | POLICY_GROUP | POLICY_GROUP...POLICY_GROUP]",
		DisableFlagsInUseLine: true, // [options] is not helpful when appended to 'use' in this context
		Short:                 "Generate an itemized diff of two policyfile lock documents",
		Long: `
Display an itemized diff comparing two revisions of a Policyfile lock.

When the '--git' option is given, '%s diff' either compares a given
git reference against the current lockfile revision on disk or compares
between two git references. Examples:

* '%s diff --git HEAD': compares the current lock with the latest
commit on the current branch.
* '%s diff --git master': compares the current lock with the latest
commit to master.
* '%s diff --git v1.0.0': compares the current lock with the revision
as of the 'v1.0.0' tag.
* '%s diff --git master...dev-branch': compares the Policyfile lock on
master with the revision on the 'dev-branch' branch.
* '%s diff --git v1.0.0...master': compares the Policyfile lock at the
'v1.0.0' tag with the lastest revision on the master branch.

'%s diff --head' is a shortcut for 'chef diff --git HEAD'.

When no git-specific flag is given, '%s diff' either compares the
current lockfile revision on disk to one on the %s or compares
two lockfiles on the %s. Lockfiles on the %s
are specified by Policy Group. Examples:

* '%s diff staging': compares the current lock with the one currently
assigned to the 'staging' Policy Group.
* '%s diff production...staging': compares the lock currently assigned
to the 'production' Policy Group to the lock currently assigned to the
'staging' Policy Group.
`,
		DisableFlagParsing: true,

		RunE: func(cmd *cobra.Command, args []string) error {
			return passThroughCommand(dist.WorkstationExec, "", os.Args[1:])
		},
	}
)

func init() {
	diffCmd.Long = fmt.Sprintf(diffCmd.Long,
		dist.CLIWrapperExec,
		dist.CLIWrapperExec,
		dist.CLIWrapperExec,
		dist.CLIWrapperExec,
		dist.CLIWrapperExec,
		dist.CLIWrapperExec,
		dist.CLIWrapperExec,
		dist.CLIWrapperExec,
		dist.ServerProduct,
		dist.ServerProduct,
		dist.ServerProduct,
		dist.CLIWrapperExec,
		dist.CLIWrapperExec)

	diffCmd.PersistentFlags().StringVarP(&gitAction, "git", "g", "", "Compare local lock against `GIT_REF`, or between two git commits")
	diffCmd.PersistentFlags().BoolVar(&head, "head", false, "Compare local lock against last git commit")
	// TODO - there are better tools for paging. Do we want to one-off support it here/in chef-cli?
	diffCmd.PersistentFlags().BoolVar(&pager, "[no-]pager", false, "Enable/disable paged diff output (default: disabled)")
	rootCmd.AddCommand(diffCmd)
}
