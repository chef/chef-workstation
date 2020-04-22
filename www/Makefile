# we use pushd/popd here, and /bin/sh of our chefes/buildkite image is not bash
# so we have to override the default shell here
SHELL=bash

assets:
	pushd themes/docs-new && make assets && popd

clean:
	pushd themes/docs-new && make clean && popd
	rm -rf resources/

clean_all:
	pushd themes/docs-new && make clean_all && popd
	rm -rf resources/
	rm -rf results/

preview_netlify: chef_web_docs_submodule
	pushd chef-web-docs && make assets; hugo --gc --minify --enableGitInfo && popd
	make reset_chef_web_docs

serve_chef_web_docs: chef_web_docs_submodule
	pushd chef-web-docs && make assets; hugo server --buildDrafts --noHTTPCache && popd

chef_web_docs_submodule:
	git submodule update --init --recursive
	git submodule foreach git pull origin master
	git submodule foreach git reset --hard
	echo "replace github.com/chef/chef-workstation/www => ../" >> chef-web-docs/go.mod

reset_chef_web_docs:
	git submodule foreach git reset --hard

serve: assets
	hugo server --buildDrafts --noHTTPCache

lint: assets
	hugo -D
