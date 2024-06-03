module github.com/chef/chef-workstation/components/main-chef-wrapper

go 1.17

require (
	github.com/chef/go-chef-cli v0.0.4
	github.com/chef/go-libs v0.4.2
	github.com/mitchellh/go-homedir v1.1.0
	github.com/spf13/cobra v1.8.0
	github.com/stretchr/testify v1.9.0
	golang.org/x/sys v0.20.0
)

require (
	github.com/davecgh/go-spew v1.1.1 // indirect
	github.com/go-chef/chef v0.24.5 // indirect
	github.com/inconshreveable/mousetrap v1.1.0 // indirect
	github.com/kr/pretty v0.2.0 // indirect
	github.com/lucasb-eyer/go-colorful v1.2.0 // indirect
	github.com/mattn/go-isatty v0.0.14 // indirect
	github.com/mattn/go-runewidth v0.0.13 // indirect
	github.com/muesli/termenv v0.11.0 // indirect
	github.com/pmezard/go-difflib v1.0.0 // indirect
	github.com/rivo/uniseg v0.2.0 // indirect
	github.com/spf13/pflag v1.0.5 // indirect
	gopkg.in/check.v1 v1.0.0-20190902080502-41f04d3bba15 // indirect
	gopkg.in/yaml.v3 v3.0.1
)

replace github.com/go-chef/chef v0.24.5 => github.com/chef/go-chef v0.4.5
