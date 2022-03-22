package chef

import (
	"fmt"
	"path"
)

// DownloadTo downloads a cookbook artifact to the specified local directory on disk
func (c *CBAService) DownloadTo(name, id, localDir string) error {

	cba, err := c.GetVersion(name, id)
	if err != nil {
		return err
	}

	debug("Downloading %s cookbook artifact with id %s\n", cba.Name, cba.Identifier)

	cookbookService := CookbookService{client: c.client}
	cookbookLongName := fmt.Sprintf("%v-%v", name, cba.Identifier[0:20])
	cookbookPath := path.Join(localDir, cookbookLongName)

	downloadErrs := []error{
		cookbookService.downloadCookbookItems(cba.RootFiles, "root_files", cookbookPath),
		cookbookService.downloadCookbookItems(cba.Files, "files", path.Join(cookbookPath, "files")),
		cookbookService.downloadCookbookItems(cba.Templates, "templates", path.Join(cookbookPath, "templates")),
		cookbookService.downloadCookbookItems(cba.Attributes, "attributes", path.Join(cookbookPath, "attributes")),
		cookbookService.downloadCookbookItems(cba.Recipes, "recipes", path.Join(cookbookPath, "recipes")),
		cookbookService.downloadCookbookItems(cba.Definitions, "definitions", path.Join(cookbookPath, "definitions")),
		cookbookService.downloadCookbookItems(cba.Libraries, "libraries", path.Join(cookbookPath, "libraries")),
		cookbookService.downloadCookbookItems(cba.Providers, "providers", path.Join(cookbookPath, "providers")),
		cookbookService.downloadCookbookItems(cba.Resources, "resources", path.Join(cookbookPath, "resources")),
	}

	for _, err := range downloadErrs {
		if err != nil {
			return err
		}
	}

	debug("Cookbook artifact downloaded to %s\n", cookbookPath)
	return nil
}
