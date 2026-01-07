// +build generate
//go:generate go run github.com/chef/go-libs/distgen global.go dist
//
// Copyright (c) 2018-2026 Progress Software Corporation and/or its subsidiaries or affiliates. All Rights Reserved.
// Author: Salim Afiune <afiune@chef.io>
//
// This file will be ignored at build time, but included for dependencies,
// it automatically generates a 'global.go' with a set of global variables

package dist

import (
	_ "github.com/chef/go-libs/distgen"
)
