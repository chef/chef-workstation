#!/bin/bash

set -eou pipefail

git clone https://github.com/chef/chef-workstation.wiki.git

pushd ./chef-workstation.wiki
  # Publish release notes to S3
  aws s3 cp Pending-Release-Notes.md "s3://chef-automate-artifacts/release-notes/chef-workstation/${version}.md" --acl public-read --content-type "text/plain" --profile chef-cd
  aws s3 cp Pending-Release-Notes.md "s3://chef-automate-artifacts/${channel}/latest/chef-workstation/release-notes.md" --acl public-read --content-type "text/plain" --profile chef-cd

  # Reset "Stable Release Notes" wiki page
  cat >./Pending-Release-Notes.md <<EOH
## New Features
-
## Improvements
-
## Bug Fixes
-
## Backward Incompatibilities
-
EOH

  # Push changes back up to GitHub
  git add .
  git commit -m "Release Notes for promoted build $version"
  git push origin master
popd

rm -rf chef-workstation.wiki
