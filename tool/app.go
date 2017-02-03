// Copyright 2015 The Go Authors. All rights reserved.
// Use of this source code is governed by a BSD-style
// license that can be found in the LICENSE file.

package main

import (
	"github.com/caothu159/grunt"
	"github.com/caothu159/window"
	"github.com/google/gxui/drivers/gl"
)

func main() {
	gl.StartDriver(window.appMain)
	grunt.Grunt = grunt.CreateGrunt()
}
