package supermarket

import (
	"github.com/chef/go-chef-cli/core"
)

var searchItemsCount = 1000

// SearchArtifact Is the struct for holding a query request
type SearchArtifact struct {
	// The query you want to execute. This is the 'chef' query ex: 'db'
	Query string

	// Sort order you want the search results returned
	SortBy string

	// Starting position for search
	Start int
	// url for where search need to hit
	Url string
	// Number of rows to return
	Rows int
}

type SearchProvider interface {
	Search(ui core.UI, config core.Config)
	String() string
}

func NewSearchProvider(query, url, artifact string) SearchProvider {

	if artifact == ArtifactCookbook {
		return CookbookSearch{
			SearchArtifact{
				Query: query,
				Start: 0,
				Rows:  searchItemsCount,
				Url:   url,
			},
		}
	}
	return nil
}
