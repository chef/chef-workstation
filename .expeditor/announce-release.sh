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

If you are running the Chef Workstation toolbar application you can download this version from the menu after the app next update check. You can also download binaries directly from [downloads.chef.io](https://downloads.chef.io/$EXPEDITOR_PRODUCT_KEY/$EXPEDITOR_VERSION).

As always, we welcome your feedback and invite you to contact us directly or share your [email](mailto:workstation@chef.io). Thanks for using Chef Workstation!
EOH
)

# Use Expeditor's built in Bash helper to post our message: https://git.io/JvxPm
post_discourse_release_announcement "$topic_title" "$topic_body"

# Cleanup
rm release-notes.md
