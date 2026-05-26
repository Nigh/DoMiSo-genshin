package main

import (
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

	content, err := svc.LoadSheet(sheets[0].Name)
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
			content, err := svc.LoadSheet(sheet.Name)
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
