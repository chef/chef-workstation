#!/bin/bash

set -exou pipefail

# Download the release-notes for our specific build
curl -o release-notes.md "https://packages.chef.io/release-notes/${EXPEDITOR_PRODUCT_KEY}/${EXPEDITOR_VERSION}.md"

topic_title="Chef Workstation $EXPEDITOR_VERSION Released!"
topic_body=$(cat <<EOH
We are delighted to announce the availability of version $EXPEDITOR_VERSION of Chef Workstation.

$(cat release-notes.md)

---
## Get the Build

If you are running the experimental application you can download this version from the menu after the app next update check. You can also download binaries directly from [downloads.chef.io](https://downloads.chef.io/$EXPEDITOR_PRODUCT_KEY/$EXPEDITOR_VERSION).

As always, we welcome your feedback and invite you to contact us directly or share your [email](mailto:workstation@chef.io). Thanks for using Chef Workstation!
EOH
)

# category 9 is "Chef Release Announcements": https://discourse.chef.io/c/chef-release

curl -X POST https://discourse.chef.io/posts \
  -H "Content-Type: multipart/form-data" \
  -F "api_username=chef-ci" \
  -F "api_key=$DISCOURSE_API_TOKEN" \
  -F "category=9" \
  -F "title=$topic_title" \
  -F "raw=$topic_body"

# Cleanup
rm release-notes.md
