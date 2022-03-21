package supermarket

import (
	"crypto/md5"
	"errors"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	"github.com/chef/go-chef-cli/core"
	"github.com/go-chef/chef"
)

type CookbookDownload struct {
	CookbookName    string
	version         string
	SpecificVersion string
	da              DownloadArtifact
}

// String implements the Stringer Interface for the SearchArtifact
func (cd CookbookDownload) String() string {
	return fmt.Sprintf("%s/api/v1/cookbooks/%s", cd.da.Url, cd.da.ArtifactName)
}

// Download will download given cookbook to given location or current dir
func (cd *CookbookDownload) Download(ui core.UI, config core.Config) error {
	client, err := chef.NewClientWithOutConfig(cd.da.Url)
	if err != nil {
		ui.Fatal(err.Error())
	}
	var cookbookData cookbookDetails
	err = client.MagicRequestResponseDecoderWithOutAuth(cd.String(), "GET", nil, &cookbookData)
	if err != nil {
		return err
	}
	if cookbookData.Deprecated {
		ui.Msg(ui.ColorMsg("DEPRECATION: This cookbook has been deprecated. ", "yellow"))
		if len(cookbookData.Replacement) > 0 {
			ui.Warn(fmt.Sprintf("It has been replaced by %s.", cookbookData.Replacement))
		} else {
			ui.Warn("No replacement has been defined.")
		}
		if !cd.da.Force {
			ui.Warn("Use --force to force download deprecated cookbook.")
			return errors.New("not able to download deprecated cookbook without force")
		}
	}

	cookbookLatestUrl := cookbookData.LatestVersion
	if len(cd.SpecificVersion) > 1 {
		cookbookLatestUrl = strings.ReplaceAll(cd.SpecificVersion, ".", "_")
	}
	var dcd cookbookDownloadDetails
	err = client.MagicRequestResponseDecoderWithOutAuth(cookbookLatestUrl, "GET", nil, &dcd)
	if err != nil {
		return err
	}
	if len(cd.da.Location) < 1 {
		cd.da.Location = downloadLocation(cd.CookbookName, dcd.Version)
		cd.version = dcd.Version
	}
	downloadCookBook(client, cd.CookbookName, cd.da.Location, dcd, ui)
	return err
}

func downloadLocation(name, version string) string {
	filename := fmt.Sprintf("%s-%s.tar.gz", name, version)
	ext, err := os.Getwd()
	if err != nil {
		ext = filepath.Join("./", filename)
	}
	return filepath.Join(ext, filename)
}

type cookbookDetails struct {
	Replacement   string `json:"replacement"`
	LatestVersion string `json:"latest_version"`
	Deprecated    bool   `json:"deprecated"`
}
type cookbookDownloadDetails struct {
	Version string `json:"version"`
	File    string `json:"file"`
	Size    int64  `json:"tarball_file_size"`
}

// func getCookBookDetails(cookBookUri string, ui core.UI) cookbookDetails {
// 	httpClient := core.GetNoAuthHTTPClient()
// 	resp, err := httpClient.Get(cookBookUri)
// 	if err != nil {
// 		ui.Fatal(err.Error())
// 	}
// 	defer resp.Body.Close()
// 	rb, err := ioutil.ReadAll(resp.Body)
// 	if err != nil {
// 		ui.Fatal(err.Error())
// 	}
// 	var response cookbookDetails
// 	err = json.Unmarshal(rb, &response)
// 	if err != nil {
// 		ui.Fatal(err.Error())
// 	}
// 	return response
// }
//
// func getCookbookDownloadDetails(cookBookUri string, ui core.UI) cookbookDownloadDetails {
// 	httpClient := core.GetNoAuthHTTPClient()
// 	resp, err := httpClient.Get(cookBookUri)
// 	if err != nil {
// 		ui.Fatal(err.Error())
// 	}
// 	defer resp.Body.Close()
// 	rb, err := ioutil.ReadAll(resp.Body)
// 	if err != nil {
// 		ui.Fatal(err.Error())
// 	}
// 	var response cookbookDownloadDetails
// 	err = json.Unmarshal(rb, &response)
// 	if err != nil {
// 		ui.Fatal(err.Error())
// 	}
// 	return response
// }

func downloadCookBook(client *chef.Client, name, fileLocation string, cbd cookbookDownloadDetails, ui core.UI) {
	ui.Msg(fmt.Sprintf("Downloading %s from Supermarket at version %s to %s", name, cbd.Version, fileLocation))
	req, err := client.NoAuthNewRequest("GET", cbd.File, nil)
	if err != nil {
		ui.Fatal(err.Error())
	}
	resp, err := client.Do(req, nil)
	if err != nil {
		ui.Fatal(err.Error())
	}
	if resp != nil {
		defer resp.Body.Close()
	}

	out, err := os.Create(fileLocation)
	if err != nil {
		ui.Fatal(err.Error())
	}
	defer out.Close()
	size, err := io.Copy(out, resp.Body)
	if err != nil {
		ui.Fatal(err.Error())
	}
	if size != cbd.Size {
		ui.Warn("cookbook size does not match. re-download or verify")
	}
	ui.Msg("Cookbook saved: " + fileLocation)
}
func (cd *CookbookDownload) Version() string {
	return cd.version
}

func verifyMD5Checksum(filePath, checksum string) bool {
	file, err := os.Open(filePath)
	if err != nil {
		return false
	}
	defer file.Close()

	hash := md5.New()
	if _, err := io.Copy(hash, file); err != nil {
		return false
	}

	md5String := fmt.Sprintf("%x", hash.Sum(nil))
	if md5String == checksum {
		return true
	}
	return false
}
