package main

import (
	"bytes"
	"embed"
	"fmt"
	"io/fs"
	"path"
	"sort"
	"strings"

	domisoparser "github.com/Nigh/domiso-parser"
)

//go:embed all:free_sheets
var sampleSheets embed.FS

type AppService struct{}

type SheetInfo struct {
	Name string `json:"name"`
	Path string `json:"path"`
}

func (a *AppService) ParseTextToMIDI(text string) ([]byte, error) {
	score, err := domisoparser.Parse(text)
	if err != nil {
		return nil, fmt.Errorf("parse error: %w", err)
	}
	var buf bytes.Buffer
	err = domisoparser.WriteMIDI(&buf, score)
	if err != nil {
		return nil, fmt.Errorf("MIDI write error: %w", err)
	}
	return buf.Bytes(), nil
}

func (a *AppService) ListFreeSheets() ([]SheetInfo, error) {
	entries, err := fs.ReadDir(sampleSheets, "free_sheets")
	if err != nil {
		return nil, fmt.Errorf("failed to read embedded free_sheets: %w", err)
	}

	var sheets []SheetInfo
	for _, entry := range entries {
		if entry.IsDir() {
			continue
		}
		name := entry.Name()
		if strings.HasSuffix(strings.ToLower(name), ".txt") {
			sheets = append(sheets, SheetInfo{
				Name: name,
				Path: path.Join("free_sheets", name),
			})
		}
	}

	sort.Slice(sheets, func(i, j int) bool {
		return sheets[i].Name < sheets[j].Name
	})

	return sheets, nil
}

func (a *AppService) LoadSheet(filename string) (string, error) {
	safeName := path.Base(filename)
	embedPath := path.Join("free_sheets", safeName)

	data, err := sampleSheets.ReadFile(embedPath)
	if err != nil {
		return "", fmt.Errorf("failed to read embedded sheet: %w", err)
	}
	return string(data), nil
}
