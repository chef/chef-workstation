package supermarket

import (
	"github.com/chef/go-chef-cli/core"
)

const superMarketUrl = "https://supermarket.chef.io"

type DownloadArtifact struct {
	// artifact download location
	Location string
	// do we need to download forcefully
	Force bool
	// artifact name for download
	ArtifactName string
	// url form where artifact  need to download
	Url string
}

type DownloadProvider interface {
	Download(ui core.UI, config core.Config) error
	Version() string
}

func NewDownloadProvider(name, url, artifact, location, specificVersion string, force bool) DownloadProvider {
	if len(url) < 1 {
		url = superMarketUrl
	}
	if artifact == ArtifactCookbook {
		return &CookbookDownload{
			CookbookName:    name,
			SpecificVersion: specificVersion,
			da: DownloadArtifact{
				ArtifactName: name,
				Url:          url,
				Location:     location,
				Force:        force,
			},
		}
	}
	return nil
}
