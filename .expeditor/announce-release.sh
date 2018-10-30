#!/bin/bash

set -eou pipefail

# Download the release-notes for our specific build
curl -o release-notes.md "https://packages.chef.io/release-notes/${product_key}/${version}.md"

topic_title="Chef Workstation $version Released!"
topic_body=$(cat <<EOH
We are delighted to announce the availability of version $version of Chef Workstation.
$(cat release-notes.md)
---
## Get the Build

As always, you can download binaries directly from [downloads.chef.io](https://downloads.chef.io/$product_key/$version) or by using the \`mixlib-install\` :

\`\`\`
$ mixlib-install download $product_key -v $version
\`\`\`

Alternatively, you can install Chef Workstation using one of the following command options:

\`\`\`
# In Shell
$ curl https://omnitruck.chef.io/install.sh | sudo bash -s -- -P $product_key -v $version

# In Windows Powershell
. { iwr -useb https://omnitruck.chef.io/install.ps1 } | iex; install -project $product_key -version $version
\`\`\`

As always, we welcome your feedback and invite you to contact us directly or share your [feedback online](https://www.chef.io/feedback/). Thanks for using Chef Workstation!
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
