//go:build !windows

package main

import "fmt"

func platformSendKey(uint16, bool) error      { return fmt.Errorf("auto play is only supported on Windows") }
func platformReleaseAllKeys()                 {}
func platformForegroundAllowed([]string) bool { return false }
func platformSetGamePracticeMonitoring(bool, []string) error {
	return fmt.Errorf("game practice monitoring is only supported on Windows")
}
func platformRegisterPerformanceHotkeys() error {
	return fmt.Errorf("global performance hotkeys are only supported on Windows")
}
