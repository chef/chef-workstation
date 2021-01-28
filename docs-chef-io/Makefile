# we use pushd/popd here, and /bin/sh of our chefes/buildkite image is not bash
# so we have to override the default shell here
SHELL=bash

clean_all:
	pushd chef-web-docs && make clean_all && popd

preview_netlify: chef_web_docs
	cp -R content/* chef-web-docs/_vendor/github.com/chef/chef-workstation/docs-chef-io/content
	cp -R static/* chef-web-docs/_vendor/github.com/chef/chef-workstation/docs-chef-io/static
	pushd chef-web-docs && make assets; hugo --buildFuture --gc --minify && popd

serve: chef_web_docs
		echo "replace github.com/chef/chef-workstation/docs-chef-io => ../" >> chef-web-docs/go.mod
	pushd chef-web-docs && make assets; hugo server --buildDrafts --buildFuture --noHTTPCache --ignoreVendorPaths "github.com/chef/chef-workstation/**" && popd

chef_web_docs:
	if [ -d "chef-web-docs/" ]; then \
		pushd chef-web-docs && git reset HEAD --hard; git pull origin master && popd; \
	else \
		git clone https://github.com/chef/chef-web-docs.git; \
	fi

# Generates blank Cookstyle Cop pages, one for each yaml file in data/workstation/cookstyle directory
# And an index page that lists all of the cops.
cookstyle_cops_pages:
	find content/workstation/cookstyle/* ! -name '_index.md' -type f -exec rm -f {} +
	dataDir=data/workstation/cookstyle; \
	for f in $$(ls $${dataDir}); \
		do echo $${f}; \
		file=$${f%.yaml}; \
		hugo new -k cops content/workstation/cookstyle/$${file}.md ; \
	done
	hugo new -k cops_list_all content/workstation/cookstyle/cops.md ;
