#!/bin/bash

# This gets run as a post-commit hook after merge to add the version tag so it
# is easy to determine what changes are in a particular build.
#
# https://expeditor.chef.io/docs/reference/action-filters/#post-commit


VERSION=`cat VERSION`

git tag $VERSION
git push origin $VERSION
