package supermarket

import (
	"os"

	"github.com/chef/go-chef-cli/core"
)

const ArtifactCookbook = "cookbook"
const ArtifactProfile = "profile"

func ValidateArgsAndType(args []string, artifact string, ui core.UI) {
	if len(artifact) > 1 && len(args) < 1 {
		ui.Msg("please provide artifact type.!")
		os.Exit(1)
	}
	if len(artifact) < 1 && len(args) < 2 {
		ui.Msg("please provide artifact type  and artifact term both.!")
		os.Exit(1)
	}

}
func isArtifactCookbook(artifact string) bool {
	return artifact == ArtifactCookbook
}

func ValidateArtifact(artifact string) bool {
	return isArtifactCookbook(artifact)
}
