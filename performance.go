package main

import (
	"fmt"
	"sync"
	"time"

	"github.com/wailsapp/wails/v3/pkg/application"
)

type KeyAction struct {
	AtMS     int64  `json:"atMs"`
	ScanCode uint16 `json:"scanCode"`
	Down     bool   `json:"down"`
}

type performanceManager struct {
	mu        sync.Mutex
	actions   []KeyAction
	processes []string
	cancel    chan struct{}
}

var performance = &performanceManager{}

func (a *AppService) PrepareKeySequence(actions []KeyAction, allowedProcesses []string) error {
	if len(actions) > 1_000_000 || len(allowedProcesses) == 0 {
		return fmt.Errorf("invalid key sequence")
	}
	var previous int64
	for _, action := range actions {
		if action.AtMS < previous || action.AtMS > int64((4*time.Hour)/time.Millisecond) || action.ScanCode == 0 {
			return fmt.Errorf("invalid key action")
		}
		previous = action.AtMS
	}
	performance.stop()
	performance.mu.Lock()
	performance.actions = append([]KeyAction(nil), actions...)
	performance.processes = append([]string(nil), allowedProcesses...)
	performance.mu.Unlock()
	return nil
}

func (a *AppService) StartAutoPlay() error {
	performance.mu.Lock()
	if performance.cancel != nil {
		performance.mu.Unlock()
		return fmt.Errorf("auto play is already running")
	}
	actions := append([]KeyAction(nil), performance.actions...)
	processes := append([]string(nil), performance.processes...)
	if len(actions) == 0 {
		performance.mu.Unlock()
		return fmt.Errorf("no prepared key sequence")
	}
	cancel := make(chan struct{})
	performance.cancel = cancel
	performance.mu.Unlock()

	go performance.run(actions, processes, cancel)
	return nil
}

func (a *AppService) PauseAutoPlay() { performance.stop() }
func (a *AppService) StopAutoPlay()  { performance.stop() }

func (a *AppService) SetGamePracticeMonitoring(enabled bool, allowedProcesses []string) error {
	return platformSetGamePracticeMonitoring(enabled, allowedProcesses)
}

func (a *AppService) RegisterPerformanceHotkeys() error {
	return platformRegisterPerformanceHotkeys()
}

func (m *performanceManager) stop() {
	m.mu.Lock()
	if m.cancel != nil {
		close(m.cancel)
		m.cancel = nil
	}
	m.mu.Unlock()
	platformReleaseAllKeys()
}

func (m *performanceManager) run(actions []KeyAction, processes []string, cancel chan struct{}) {
	defer func() {
		platformReleaseAllKeys()
		m.mu.Lock()
		if m.cancel == cancel {
			m.cancel = nil
		}
		m.mu.Unlock()
	}()
	started := time.Now()
	for _, action := range actions {
		wait := time.Until(started.Add(time.Duration(action.AtMS) * time.Millisecond))
		if wait > 0 {
			timer := time.NewTimer(wait)
			select {
			case <-cancel:
				timer.Stop()
				return
			case <-timer.C:
			}
		}
		if !platformForegroundAllowed(processes) {
			emitPerformanceEvent("performance:stopped", "game-not-foreground")
			return
		}
		if err := platformSendKey(action.ScanCode, action.Down); err != nil {
			emitPerformanceEvent("performance:error", err.Error())
			return
		}
	}
	emitPerformanceEvent("performance:stopped", "complete")
}

func emitPerformanceEvent(name string, data any) {
	if app := application.Get(); app != nil {
		app.Event.Emit(name, data)
	}
}
