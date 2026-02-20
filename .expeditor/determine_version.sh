#!/bin/bash
set -euo pipefail


# Read current version parts
MAJOR=$(cut -d. -f1 VERSION)
MINOR=$(cut -d. -f2 VERSION)
OLD_BUILD=$(cut -d. -f3 VERSION)


NEW_BUILD=$((OLD_BUILD + 1))


echo "${MAJOR}.${MINOR}.${NEW_BUILD}" > VERSION