package main

import (
	"fmt"
	"os"
	"runtime"
)

var version string

func mains() error {
	fmt.Printf("Sample %s-%s-%s by %s\n",
		version, runtime.GOOS, runtime.GOARCH, runtime.Version())
	return nil
}

func main() {
	if err := mains(); err != nil {
		fmt.Fprintln(os.Stderr, err.Error())
		os.Exit(1)
	}
}
