package core

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"strings"
)

func checkErrorOrExit(data string, err error) {
	if err != nil {
		fmt.Println(data)
		fmt.Println(err.Error())
		os.Exit(1)
	}
}

func IsBranchExists(branch, path string) bool {
	cmdData, err := executeCmd("git", path, "branch")
	checkErrorOrExit(cmdData, err)
	matched, _ := regexp.MatchString(branch, cmdData)
	return matched
}

func CheckoutToExistingBranch(branch, path string) bool {
	fmt.Printf("Checking out the %s branch.\n", branch)
	cmdData, err := executeCmd("git", path, []string{"checkout", branch}...)
	checkErrorOrExit(cmdData, err)
	matched, _ := regexp.MatchString(branch, cmdData)
	return matched

}
func CheckoutToNewBranch(branch, path string) bool {
	cmdData, err := executeCmd("git", path, []string{"checkout", "-b", branch}...)
	checkErrorOrExit(cmdData, err)
	matched, _ := regexp.MatchString(branch, cmdData)
	return matched

}

func GetCurrentBranch(path string) string {
	cmdData, err := executeCmd("git", path, []string{"symbolic-ref", "HEAD"}...)
	checkErrorOrExit(cmdData, err)
	branch := strings.Split(cmdData, "/")[2]
	return branch
}

func DoesGitRepoExist(path string) bool {
	path = filepath.Join(path, ".git")
	return doesDirExist(path)
}

func IsUnCommittedWorkPresent(path string) (bool, string) {
	re := "\\s+M"
	cmdData, err := executeCmd("git", path, []string{"status", "--porcelain"}...)
	checkErrorOrExit(cmdData, err)
	matched, _ := regexp.Match(re, []byte(cmdData))
	return matched, cmdData

}
func executeCmd(cmd, path string, args ...string) (string, error) {
	cmdEnv := exec.Command(cmd, args...)
	cmdEnv.Dir = path
	cmdEnv.Env = os.Environ()
	data, err := cmdEnv.Output()
	return string(data), err
}

func doesDirExist(path string) bool {
	info, err := os.Stat(path)
	if err != nil {
		return false
	}
	return info.IsDir()
}
func SanityCheck(path, defaultBranch string, useCurrentBranch bool, ui UI) bool {
	if !doesDirExist(path) {
		ui.Error(fmt.Sprintf("The cookbook repo path %s does not exist or is not a directory", path))
		os.Exit(1)
	}
	if !DoesGitRepoExist(path) {
		ui.Error(fmt.Sprintf("The cookbook repo %s is not a git repository.", path))
		ui.Msg("Use `git init` to initialize a git repo")
		os.Exit(1)
	}
	if useCurrentBranch {
		defaultBranch = GetCurrentBranch(path)
	}
	if !IsBranchExists(defaultBranch, path) {
		ui.Error(fmt.Sprintf("The default branch '%s' does not exist", defaultBranch))
		ui.Msg("If this is a new git repo, make sure you have at least one commit before installing cookbooks")
		os.Exit(1)
	}
	found, data := IsUnCommittedWorkPresent(path)
	if found {
		ui.Error(fmt.Sprintf("You have uncommitted changes to your cookbook repo (%s):", path))
		ui.Msg(data)
		ui.Msg("Commit or stash your changes before importing cookbooks")
		os.Exit(1)
	}
	return true
}

func UpdateCount(cookbookName, path string) int {
	cmdData, err := executeCmd("git", path, []string{"status", "--porcelain", cookbookName}...)
	checkErrorOrExit(cmdData, err)
	cmdData = strings.TrimSpace(cmdData)
	if cmdData == "" {
		return 0
	}
	data := strings.Split(cmdData, "\n")
	return len(data)
}

func FinalizeUpdates(cookbookName, path, version string, ui UI) bool {
	updateCount := UpdateCount(cookbookName, path)
	if updateCount > 0 {
		ui.Msg(fmt.Sprintf("%d files updated, committing changes", updateCount))
		cmdData, err := executeCmd("git", path, []string{"add", cookbookName}...)
		checkErrorOrExit(cmdData, err)
		ui.Msg(cmdData)
		cmdData, err = executeCmd("git", path, []string{"commit", "-m", fmt.Sprintf(`"Import %s version %s -- %s"`, cookbookName, version, cookbookName)}...)
		checkErrorOrExit(cmdData, err)
		ui.Msg(cmdData)
		ui.Msg(fmt.Sprintf("Creating tag cookbook-site-imported-%s-%s", cookbookName, version))
		cmdData, err = executeCmd("git", path, []string{"tag", "-f", fmt.Sprintf("cookbook-site-imported-%s-%s", cookbookName, version)}...)
		checkErrorOrExit(cmdData, err)
		ui.Msg(cmdData)
		return true
	} else {
		ui.Msg(fmt.Sprintf("No changes made to %s", cookbookName))
		return false
	}
}
func MergeUpdates(cookbookName, path, version string, ui UI) {
	branch := fmt.Sprintf("chef-vendor-%s", cookbookName)
	cmdData, err := executeCmd("git", path, []string{"merge", branch}...)
	if _, ok := err.(*exec.ExitError); ok {
		ui.Msg("You have merge conflicts - please resolve manually")
		ui.Msg(fmt.Sprintf("Merge status (cd %s; git status):", path))
		cmdData, _ := executeCmd("git", path, []string{"status"}...)
		ui.Msg(cmdData)
		os.Exit(3)
	}
	ui.Msg(cmdData)
	ui.Msg(fmt.Sprintf("Cookbook %s version %s successfully installed", cookbookName, version))

}
