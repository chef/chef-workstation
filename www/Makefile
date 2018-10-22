# we use pushd/popd here, and /bin/sh of our chefes/buildkite image is not bash
# so we have to override the default shell here
SHELL=bash

chef-www:
	git clone https://github.com/chef/chef-www.git chef-www

site/themes/chef:
	git clone https://github.com/chef/chef-hugo-theme.git site/themes/chef

clean:
	rm -rf chef-sh
	rm -rf chef-www
	rm -rf site/layouts
	rm -rf site/themes/chef

sync: chef-www site/themes/chef
	pushd chef-www && git fetch && git reset --hard origin/master && popd
	pushd site/themes/chef && git fetch && git reset --hard origin/master && popd
	cp -R chef-www/site/layouts site/
	aws --profile chef-cd s3 sync s3://chef-www-acceptance.cd.chef.co chef-sh --delete

serve: sync
	cd site && hugo server --buildDrafts --noHTTPCache

lint: chef-www site/themes/chef
	pushd site && hugo -D && popd
