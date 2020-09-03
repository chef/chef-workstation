package integration

import (
	"testing"

	"github.com/stretchr/testify/assert"
)

func TestHelpCommand(t *testing.T) {
	expected := `Collect data for Chef Automate

Usage:
  chef-automate-collect [command]

Available Commands:
  describe           Prints metadata about the Chef Infra policy to stdout
  gen-config         verify config parameters and emit config
  help               Help about any command
  report-new-rollout Gather metadata about a new Chef Infra code rollout and report it to Chef Automate
  show-config        Load config files and environment variables and show the resulting configuration
  test-config        Make a request to the test API

Flags:
  -h, --help   help for chef-automate-collect

Use "chef-automate-collect [command] --help" for more information about a command.
`
	out, err, exitcode := ChefAutoCollect("help")
	assert.Equal(t, expected, out.String())
	assert.Empty(t, err.String(), "STDERR should be empty")
	assert.Equal(t, 0, exitcode, "EXITCODE is not the expected one")
}

func TestHelpFlags_h(t *testing.T) {
	out, err, exitcode := ChefAutoCollect("-h")
	expected := `Collect data for Chef Automate

Usage:
  chef-automate-collect [command]

Available Commands:
  describe           Prints metadata about the Chef Infra policy to stdout
  gen-config         verify config parameters and emit config
  help               Help about any command
  report-new-rollout Gather metadata about a new Chef Infra code rollout and report it to Chef Automate
  show-config        Load config files and environment variables and show the resulting configuration
  test-config        Make a request to the test API

Flags:
  -h, --help   help for chef-automate-collect

Use "chef-automate-collect [command] --help" for more information about a command.
`
	assert.Equal(t, expected, out.String())
	assert.Empty(t, err.String(), "STDERR should be empty")
	assert.Equal(t, 0, exitcode, "EXITCODE is not the expected one")
}

func TestHelpFlags__help(t *testing.T) {
	out, err, exitcode := ChefAutoCollect("--help")
	expected := `Collect data for Chef Automate

Usage:
  chef-automate-collect [command]

Available Commands:
  describe           Prints metadata about the Chef Infra policy to stdout
  gen-config         verify config parameters and emit config
  help               Help about any command
  report-new-rollout Gather metadata about a new Chef Infra code rollout and report it to Chef Automate
  show-config        Load config files and environment variables and show the resulting configuration
  test-config        Make a request to the test API

Flags:
  -h, --help   help for chef-automate-collect

Use "chef-automate-collect [command] --help" for more information about a command.
`
	assert.Equal(t, expected, out.String())
	assert.Empty(t, err.String(), "STDERR should be empty")
	assert.Equal(t, 0, exitcode, "EXITCODE is not the expected one")
}
