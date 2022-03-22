package supermarket

import (
	"github.com/chef/go-chef-cli/core"
)

type InstallArtifact struct {
	// artifact install location
	Location string

	// artifact name for download
	ArtifactName string
	da           DownloadArtifact
}
type InstallProvider interface {
	Install(ui core.UI, config core.Config)
	InstallDeps() bool
	ChangeArtifactName(artifactName string)
}

func NewInstallProvider(cookbookName, url, location, defaultBranch, artifact string, installDeps, useCurrentBranch bool) InstallProvider {

	if artifact == ArtifactCookbook {
		return CookbookInstall{
			UseCurrentBranch: useCurrentBranch,
			DefaultBranch:    defaultBranch,
			InstallDep:       installDeps,
			InstallArtifact: InstallArtifact{
				Location:     location,
				ArtifactName: cookbookName,
				da: DownloadArtifact{
					Location:     location,
					ArtifactName: cookbookName,
					Url:          url,
				},
			},
		}
	}
	return nil
}
