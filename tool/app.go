package main

import (
	"github.com/caothu159/window"
	"github.com/google/gxui/drivers/gl"
)

func main() {
	gl.StartDriver(window.Init)
}
