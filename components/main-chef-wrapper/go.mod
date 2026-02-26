module github.com/chef/chef-workstation/components/main-chef-wrapper

go 1.26

require (
	github.com/chef/go-chef-cli v0.0.4
	github.com/chef/go-libs v0.4.2
	github.com/mitchellh/go-homedir v1.1.0
	github.com/spf13/cobra v1.10.2
	github.com/stretchr/testify v1.11.1
	golang.org/x/sys v0.41.0
	gopkg.in/yaml.v3 v3.0.1
)

require (
	github.com/aymanbagabas/go-osc52/v2 v2.0.1 // indirect
	github.com/davecgh/go-spew v1.1.1 // indirect
	github.com/go-chef/chef v0.30.1 // indirect
	github.com/inconshreveable/mousetrap v1.1.0 // indirect
	github.com/kr/pretty v0.2.0 // indirect
	github.com/lucasb-eyer/go-colorful v1.3.0 // indirect
	github.com/mattn/go-isatty v0.0.20 // indirect
	github.com/muesli/termenv v0.16.0 // indirect
	github.com/pmezard/go-difflib v1.0.0 // indirect
	github.com/rivo/uniseg v0.4.7 // indirect
	github.com/spf13/pflag v1.0.10 // indirect
	gopkg.in/check.v1 v1.0.0-20190902080502-41f04d3bba15 // indirect
)

replace github.com/go-chef/chef v0.24.5 => github.com/chef/go-chef v0.4.5

// Security fix for CVE-2024-45337: Force golang.org/x/crypto to v0.31.0 or later
// This replace directive ensures all indirect dependencies use the secure version
replace golang.org/x/crypto => golang.org/x/crypto v0.31.0

// Security fix for CVE-2022-32149: Force golang.org/x/text to v0.3.8 or later
// This replace directive ensures all indirect dependencies use the secure version
replace golang.org/x/text => golang.org/x/text v0.3.8
