# we use pushd/popd here, and /bin/sh of our chefes/buildkite image is not bash
# so we have to override the default shell here
SHELL=bash

clean_all:
	pushd chef-web-docs && make clean_all && popd

preview_netlify: chef_web_docs
	rm -rf chef-web-docs/_vendor/github.com/chef/chef-workstation/docs-chef-io/*
	cp -R content chef-web-docs/_vendor/github.com/chef/chef-workstation/docs-chef-io/content
	cp -R static chef-web-docs/_vendor/github.com/chef/chef-workstation/docs-chef-io/static

	if [ -d "layouts" ]; then \
		cp -R layouts chef-web-docs/_vendor/github.com/chef/chef-workstation/docs-chef-io/layouts; \
	fi

	cp -R config.toml chef-web-docs/_vendor/github.com/chef/chef-workstation/docs-chef-io/
	pushd chef-web-docs && bash ./scripts/netlify-deploy-preview.sh && popd

serve: chef_web_docs
	printf "go 1.22\n\nuse .\nuse ../" > chef-web-docs/hugo.work
	pushd chef-web-docs && make bundle && HUGO_MODULE_WORKSPACE=hugo.work hugo server --buildDrafts --buildFuture --noHTTPCache --ignoreVendorPaths "github.com/chef/chef-workstation/docs-chef-io" && popd

chef_web_docs:
	if [ -d "chef-web-docs/" ]; then \
		pushd chef-web-docs && git reset HEAD --hard; git clean -fd; git pull --ff-only origin main; rm -rf public && popd; \
	else \
		git clone https://github.com/chef/chef-web-docs.git; \
	fi
