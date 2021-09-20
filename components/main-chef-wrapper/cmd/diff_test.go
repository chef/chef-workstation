package cmd

import (
	"log"
	"testing"

	"github.com/chef/chef-workstation/components/main-chef-wrapper/dist"
	"github.com/spf13/cobra"
)

func NewDiffCmd(s []string) *cobra.Command {
	return &cobra.Command{
		Use:                   "diff [Policyfile] [--head | --git GIT_REF | POLICY_GROUP | POLICY_GROUP...POLICY_GROUP]",
		DisableFlagsInUseLine: true, // [options] is not helpful when appended to 'use' in this context
		Short:                 "Generate an itemized diff of two Policyfile lock documents",
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
		RunE: func(cmd *cobra.Command, args []string) error {
			return PassThroughCommand(dist.WorkstationExec, "", s)
		},
	}
}

func Test_DiffCommand(t *testing.T) {
	s := []string{"diff"}
	cmd := NewDiffCmd(s)
	err := cmd.Execute()
	if err != nil {
		log.Printf("Command finished with error: %v", err)
	}
}

// func Test_DiffArgsCommand(t *testing.T) {
// 	s := []string{"install", "/Users/ngupta/Documents/projects/chef-workstation/chef-workstation/components/main-chef-wrapper/test100/Policyfile.rb"}
// 	cmd := NewDiffCmd(s)
// 	b := bytes.NewBufferString("")
// 	cmd.SetOut(b)
// 	cmd.Execute()
// 	out, err := ioutil.ReadAll(b)
// 	if err != nil {
// 		t.Fatal(err)
// 	}
// 	if string(out) != `` {
// 		t.Fatalf("expected \"%s\" got \"%s\"", ``, string(out))
// 	}
// }
