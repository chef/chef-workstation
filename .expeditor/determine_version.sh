#!/bin/bash

# This gets run as a pre-commit hook just prior to a merge to
# determine the new version number.

# Leading zeros are not permitted in strict SemVer
YEAR=`date +"%y" | sed -e 's/^0//'` # Must be < 256 per Microsoft
MONTH=`date +"%m" | sed -e 's/^0//'`

OLD_BUILD=`cut -f3 -d. < VERSION`

NEW_BUILD=$(($OLD_BUILD + 1)) # Monotonically increase the build number

echo $YEAR.$MONTH.$NEW_BUILD > VERSION
