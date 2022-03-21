package supermarket

import (
	"archive/tar"
	"compress/gzip"
	"fmt"
	"io"
	"os"
	"path/filepath"
	"strings"

	"github.com/chef/go-chef-cli/core"
)

type CookbookInstall struct {
	UseCurrentBranch bool
	DefaultBranch    string
	InstallDep       bool
	InstallArtifact
}

func (ci CookbookInstall) Install(ui core.UI, config core.Config) {
	ui.Msg(fmt.Sprintf("Installing %s to %s", ci.ArtifactName, ci.Location))
	core.SanityCheck(ci.Location, ci.DefaultBranch, ci.UseCurrentBranch, ui)
	if ci.UseCurrentBranch {
		ui.Msg(fmt.Sprintf("Checking out the %s branch.", ci.DefaultBranch))
		ci.DefaultBranch = core.GetCurrentBranch(ci.Location)
		core.CheckoutToExistingBranch(ci.DefaultBranch, ci.Location)
	}
	prepareToImport(ci.ArtifactName, ci.Location, ui)
	cookBookInstallPath := filepath.Join(ci.Location, fmt.Sprintf("%s.tar.gz", ci.ArtifactName))
	dp := NewDownloadProvider(ci.ArtifactName, "", ArtifactCookbook, filepath.Join(ci.Location, ci.ArtifactName+".tar.gz"), "", false)
	err := dp.Download(ui, config)
	if err != nil {
		ui.Error(err.Error())
		os.Exit(1)
	}
	clearExistingFiles(ci.Location, ci.ArtifactName, ui)
	extractCookbook(ci.Location, cookBookInstallPath, ci.ArtifactName, dp.Version(), ui)
	ui.Msg("Removing downloaded tarball")
	os.Remove(cookBookInstallPath)
	if core.FinalizeUpdates(ci.ArtifactName, ci.Location, dp.Version(), ui) {
		core.CheckoutToExistingBranch(ci.DefaultBranch, ci.Location)
		core.MergeUpdates(ci.ArtifactName, ci.Location, dp.Version(), ui)
	} else {
		core.CheckoutToExistingBranch(ci.DefaultBranch, ci.Location)
	}
}

func (ci CookbookInstall) InstallDeps() bool {
	return ci.InstallDep
}

func (ci CookbookInstall) ChangeArtifactName(artifactName string) {
	ci.ArtifactName = artifactName
	ci.da.ArtifactName = artifactName
}

func prepareToImport(cookBookName, installPath string, ui core.UI) {
	branch := fmt.Sprintf("chef-vendor-%s", cookBookName)
	if core.IsBranchExists(branch, installPath) {
		ui.Msg(fmt.Sprintf("Pristine copy branch (%s) exists, switching to it.", branch))
		core.CheckoutToExistingBranch(branch, installPath)
	} else {
		ui.Msg(fmt.Sprintf("Creating pristine copy branch %s", branch))
		core.CheckoutToNewBranch(branch, installPath)
	}
}
func clearExistingFiles(installPath, cookbookName string, ui core.UI) {
	ui.Msg("Removing pre-existing version.")
	dir := filepath.Join(installPath, cookbookName+"/")
	info, err := os.Stat(dir)
	if err == nil && info.IsDir() {
		os.RemoveAll(dir)
	}
}
func extractCookbook(installPath, sourceFile, name, version string, ui core.UI) {
	ui.Msg(fmt.Sprintf("Uncompressing %s version %s.", name, version))
	file, err := os.Open(sourceFile)
	if err != nil {
		ui.Error(err.Error())
		os.Exit(1)
	}
	defer file.Close()
	var fileReader io.ReadCloser = file
	// just in case we are reading a tar.gz file, add a filter to handle gzipped file
	if strings.HasSuffix(sourceFile, ".gz") {
		if fileReader, err = gzip.NewReader(file); err != nil {
			ui.Error(err.Error())
			os.Exit(1)
		}
		defer fileReader.Close()
	}
	tarBallReader := tar.NewReader(fileReader)
	// Extracting tarred files
	for {
		header, err := tarBallReader.Next()
		if err != nil {
			if err == io.EOF {
				break
			}
			ui.Error(err.Error())
			os.Exit(1)
		}
		filename := header.Name
		switch header.Typeflag {
		case tar.TypeDir:
			// handle directory
			err = os.MkdirAll(filepath.Join(installPath, filename), os.FileMode(header.Mode))
			if err != nil {
				ui.Error(err.Error())
				os.Exit(1)
			}

		case tar.TypeReg:
			// handle normal file
			writer, err := os.Create(filepath.Join(installPath, filename))
			if err != nil && os.IsExist(err) {
				ui.Error(err.Error())
				os.Exit(1)
			} else {
				f := strings.Split(filename, "/")
				tempFileName := strings.Join(f[:len(f)-1], "/")
				err = os.MkdirAll(filepath.Join(installPath, tempFileName), 0755)
				if err != nil {
					ui.Error(err.Error())
					os.Exit(1)
				}
				writer, err = os.Create(filepath.Join(installPath, tempFileName, f[len(f)-1]))
				if err != nil && os.IsExist(err) {
					ui.Error(err.Error())
					os.Exit(1)
				}
			}
			io.Copy(writer, tarBallReader)
			err = os.Chmod(filepath.Join(installPath, filename), os.FileMode(header.Mode))
			if err != nil {
				ui.Error(err.Error())
				os.Exit(1)
			}
			writer.Close()
		default:
			ui.Fatal(fmt.Sprintf("Unable to untar type : %c in file %s", header.Typeflag, filename))
		}
	}
}
