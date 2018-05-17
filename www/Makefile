sync:
	git submodule update --init --remote --rebase
	aws --profile chef-cd s3 sync s3://chef-www-acceptance.cd.chef.co chef-sh --delete

serve: sync
	cd site && hugo server --buildDrafts --noHTTPCache
