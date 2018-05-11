sync:
	git submodule update
	aws --profile chef-cd s3 sync s3://chef-www-acceptance.cd.chef.co chef-sh --delete

serve:
	cd site && hugo server --buildDrafts
