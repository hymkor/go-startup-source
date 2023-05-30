package main

import (
	"fmt"
	"os"
	"path/filepath"
	"runtime"
)

var version string

func progName(path string) string {
	return filepath.Base(path[:len(path)-len(filepath.Ext(path))])
}

func mains() error {
	fmt.Printf("%s %s-%s-%s by %s\n",
		progName(os.Args[0]),
		version, runtime.GOOS, runtime.GOARCH, runtime.Version())
	return nil
}

func main() {
	if err := mains(); err != nil {
		fmt.Fprintln(os.Stderr, err.Error())
		os.Exit(1)
	}
}
