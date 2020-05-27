# we use pushd/popd here, and /bin/sh of our chefes/buildkite image is not bash
# so we have to override the default shell here
SHELL=bash

assets:
	git submodule update --init --recursive
	pushd chef-web-docs/themes/docs-new && make assets && popd

clean:
	pushd chef-web-docs/themes/docs-new && make clean && popd
	rm -rf chef-web-docs/resources/

clean_all:
	pushd chef-web-docs/themes/docs-new && make clean_all && popd
	rm -rf chef-web-docs/resources/
	rm -rf chef-web-docs/results/

preview_netlify: chef_web_docs_submodule
	pushd chef-web-docs && make assets; hugo --gc --minify --enableGitInfo --buildFuture && popd
	make reset_chef_web_docs

serve_chef_web_docs: chef_web_docs_submodule
	pushd chef-web-docs && make assets; hugo server --buildDrafts --noHTTPCache --buildFuture && popd

chef_web_docs_submodule:
	git submodule update --init --recursive
	git submodule foreach git pull origin master
	git submodule foreach git reset --hard
	echo "replace github.com/chef/chef-workstation/www => ../" >> chef-web-docs/go.mod

reset_chef_web_docs:
	git submodule foreach git reset --hard

serve: assets
	cd chef-web-docs
	hugo server --buildDrafts --noHTTPCache --buildFuture

lint: assets
	hugo -D
