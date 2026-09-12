package main

import (
	"encoding/json"
	"os"
	"path/filepath"
	"testing"
)

func TestParseTextToMIDI(t *testing.T) {
	svc := &AppService{}

	sheet := `1=C 4/4 80
1 2 3 4 | 5 6 7 1`

	midiBytes, err := svc.ParseTextToMIDI(sheet)
	if err != nil {
		t.Fatalf("ParseTextToMIDI failed: %v", err)
	}

	if len(midiBytes) == 0 {
		t.Fatal("MIDI bytes are empty")
	}

	// Check MIDI header: "MThd"
	if midiBytes[0] != 'M' || midiBytes[1] != 'T' || midiBytes[2] != 'h' || midiBytes[3] != 'd' {
		t.Fatalf("Invalid MIDI header: %q", string(midiBytes[:4]))
	}

	t.Logf("Generated %d bytes of MIDI data", len(midiBytes))
}

func TestParseTextToMIDI_Chord(t *testing.T) {
	svc := &AppService{}

	sheet := `1=C 4/4 120
[135] 2 [246] 3`

	midiBytes, err := svc.ParseTextToMIDI(sheet)
	if err != nil {
		t.Fatalf("ParseTextToMIDI failed: %v", err)
	}

	if len(midiBytes) == 0 {
		t.Fatal("MIDI bytes are empty")
	}

	t.Logf("Generated %d bytes of MIDI data (chords)", len(midiBytes))
}

func TestParseTextToMIDI_InvalidInput(t *testing.T) {
	svc := &AppService{}

	// Empty input should still produce a valid (empty) MIDI
	_, err := svc.ParseTextToMIDI("")
	// Note: domiso-parser may or may not error on empty input
	t.Logf("Empty input result: err=%v", err)
}

func TestListFreeSheets(t *testing.T) {
	svc := &AppService{}

	sheets, err := svc.ListFreeSheets()
	if err != nil {
		t.Fatalf("ListFreeSheets failed: %v", err)
	}

	if len(sheets) == 0 {
		t.Fatal("No free sheets found")
	}

	t.Logf("Found %d free sheets:", len(sheets))
	for _, s := range sheets {
		t.Logf("  - %s (%s)", s.Name, s.Path)
	}
}

func TestLoadSheet(t *testing.T) {
	svc := &AppService{}

	sheets, err := svc.ListFreeSheets()
	if err != nil {
		t.Fatalf("ListFreeSheets failed: %v", err)
	}

	if len(sheets) == 0 {
		t.Skip("No sheets to test")
	}

	content, err := svc.LoadSheet(sheets[0].Path)
	if err != nil {
		t.Fatalf("LoadSheet failed: %v", err)
	}

	if len(content) == 0 {
		t.Fatal("Sheet content is empty")
	}

	t.Logf("Loaded sheet '%s' (%d chars)", sheets[0].Name, len(content))
}

func TestLoadSheet_ParseRoundTrip(t *testing.T) {
	svc := &AppService{}

	sheets, err := svc.ListFreeSheets()
	if err != nil {
		t.Fatalf("ListFreeSheets failed: %v", err)
	}

	for _, sheet := range sheets {
		t.Run(sheet.Name, func(t *testing.T) {
			content, err := svc.LoadSheet(sheet.Path)
			if err != nil {
				t.Fatalf("LoadSheet failed: %v", err)
			}

			midiBytes, err := svc.ParseTextToMIDI(content)
			if err != nil {
				t.Fatalf("ParseTextToMIDI failed for '%s': %v", sheet.Name, err)
			}

			if len(midiBytes) == 0 {
				t.Fatalf("MIDI bytes empty for '%s'", sheet.Name)
			}

			t.Logf("'%s': %d chars -> %d bytes MIDI", sheet.Name, len(content), len(midiBytes))
		})
	}
}

func TestParseSheetStats(t *testing.T) {
	svc := &AppService{}

	sheet := `1=C 4/4 80
1 2 3 4 | 5 6 7 1`

	stats, err := svc.ParseSheetStats(sheet)
	if err != nil {
		t.Fatalf("ParseSheetStats failed: %v", err)
	}

	if stats.NoteCount == 0 {
		t.Fatal("Expected non-zero note count")
	}
	if stats.BPM != 80 {
		t.Fatalf("Expected BPM 80, got %d", stats.BPM)
	}
	t.Logf("Stats: %d notes, %.2f measures, %.2f sec, BPM=%d",
		stats.NoteCount, stats.MeasureCount, stats.DurationSec, stats.BPM)
}

func TestImportSheet_JSON(t *testing.T) {
	svc := &AppService{}
	tmpDir := t.TempDir()

	sheet := SheetJSON{
		Version: 1,
		Meta: SheetMeta{
			Title:    "Test Song",
			Composer: "Test Composer",
		},
		Notation: "1=C 4/4 80\n1 2 3 4",
	}
	data, _ := json.Marshal(sheet)
	jsonPath := filepath.Join(tmpDir, "test.json")
	os.WriteFile(jsonPath, data, 0644)

	result, err := svc.ImportSheet(jsonPath)
	if err != nil {
		t.Fatalf("ImportSheet failed: %v", err)
	}
	if result.Format != "json" {
		t.Fatalf("Expected format 'json', got '%s'", result.Format)
	}
	if result.Meta.Title != "Test Song" {
		t.Fatalf("Expected title 'Test Song', got '%s'", result.Meta.Title)
	}
	if result.Content != "1=C 4/4 80\n1 2 3 4" {
		t.Fatalf("Content mismatch: %s", result.Content)
	}
}

func TestImportSheet_TXT(t *testing.T) {
	svc := &AppService{}
	tmpDir := t.TempDir()

	txtPath := filepath.Join(tmpDir, "test.txt")
	os.WriteFile(txtPath, []byte("标题: Test\n记谱: Me\n\n=====\n1=C\n1 2 3 4"), 0644)

	result, err := svc.ImportSheet(txtPath)
	if err != nil {
		t.Fatalf("ImportSheet failed: %v", err)
	}
	if result.Format != "txt" {
		t.Fatalf("Expected format 'txt', got '%s'", result.Format)
	}
}

func TestExportSheet_JSON(t *testing.T) {
	svc := &AppService{}
	tmpDir := t.TempDir()

	jsonPath := filepath.Join(tmpDir, "export.json")
	meta := SheetMeta{Title: "Export Test", Composer: "Tester"}
	err := svc.ExportSheet(jsonPath, meta, "1=C\n1 2 3 4", "", false)
	if err != nil {
		t.Fatalf("ExportSheet failed: %v", err)
	}

	data, _ := os.ReadFile(jsonPath)
	var sheet SheetJSON
	json.Unmarshal(data, &sheet)
	if sheet.Meta.Title != "Export Test" {
		t.Fatalf("Expected title 'Export Test', got '%s'", sheet.Meta.Title)
	}
	if sheet.Notation != "1=C\n1 2 3 4" {
		t.Fatalf("Notation mismatch")
	}
	if sheet.Version != 2 || sheet.MIDI != "" || sheet.NotationOutOfSync {
		t.Fatalf("unexpected text-only sheet: %+v", sheet)
	}
}

func TestExportSheet_TXT(t *testing.T) {
	svc := &AppService{}
	tmpDir := t.TempDir()

	txtPath := filepath.Join(tmpDir, "export.txt")
	meta := SheetMeta{Title: "Export Test", Composer: "Tester"}
	err := svc.ExportSheet(txtPath, meta, "1=C\n1 2 3 4", "", false)
	if err != nil {
		t.Fatalf("ExportSheet failed: %v", err)
	}

	data, _ := os.ReadFile(txtPath)
	content := string(data)
	if len(content) == 0 {
		t.Fatal("Exported file is empty")
	}
	t.Logf("Exported TXT:\n%s", content)
}

func TestExportSheet_EditedMIDIRoundTrip(t *testing.T) {
	svc := &AppService{}
	filePath := filepath.Join(t.TempDir(), "edited.json")
	midi := "TVRoZAAAAAYAAQABAeBNVHJrAAAABAD/LwA="
	if err := svc.ExportSheet(filePath, SheetMeta{Title: "Edited"}, "1 2", midi, true); err != nil {
		t.Fatal(err)
	}
	result, err := svc.ImportSheet(filePath)
	if err != nil {
		t.Fatal(err)
	}
	if result.MIDI != midi || !result.NotationOutOfSync || result.Content != "1 2" {
		t.Fatalf("unexpected round trip: %+v", result)
	}
}

func TestExportSheet_RejectsEditedMIDIAsText(t *testing.T) {
	svc := &AppService{}
	midi := "TVRoZAAAAAYAAQABAeBNVHJrAAAABAD/LwA="
	err := svc.ExportSheet(filepath.Join(t.TempDir(), "edited.txt"), SheetMeta{}, "1", midi, true)
	if err == nil {
		t.Fatal("expected edited MIDI text export to fail")
	}
}
