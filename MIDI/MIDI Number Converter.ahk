#NoEnv

/*
Copyright 2011-2012 Anthony Zhang <azhang9@gmail.com>

This file is part of ProgressPlatformer. Source code is available at <https://github.com/Uberi/ProgressPlatformer>.

ProgressPlatformer is free software: you can redistribute it and/or modify
it under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Affero General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

;wip: playing functionality
#Include ../midi_data.ahk

NoteTable := Object()
NumberTable := Object()
Loop, Parse, NoteData, `n
{
    StringSplit, Field, A_LoopField, %A_Space%
    NoteTable[Field2] := Field1
    NumberTable[Field1] := Field2
}

Gui, Font, Bold s12, Arial
Gui, Add, Text, x10 y10 h30 vPromptText, Enter tune:
Gui, Font, Norm s10
Gui, Add, Edit, x10 y50 w480 h380 vTune

Gui, Font, Bold
Gui, Add, Text, x10 y440 w80 h20 vInstrumentLabel, Instrument:
Gui, Font, Norm
Gui, +Delimiter`n
Gui, Add, DropDownList, x90 y440 w400 h20 vInstrument R30 Choose1 AltSubmit, %Instruments%

Gui, Font, s12
Gui, Add, Button, x10 y470 w320 h30 vPlayButton gPlay Default, &Play
Gui, Add, Button, x340 y470 w150 h30 vConvertButton gConvert, &Convert

Gui, +Resize +MinSize350x200
Gui, Show, w500 h510, Note Editor
Return

GuiClose:
ExitApp

GuiSize:
GuiControl, Move, PromptText, % "w" . (A_GuiWidth - 20)
GuiControl, Move, Tune, % "w" . (A_GuiWidth - 20) . " h" . (A_GuiHeight - 130)
GuiControl, Move, InstrumentLabel, % "y" . (A_GuiHeight - 70)
GuiControl, Move, Instrument, % "y" . (A_GuiHeight - 70) . " w" . (A_GuiWidth - 100)
GuiControl, Move, PlayButton, % "y" . (A_GuiHeight - 40) . " w" . (A_GuiWidth - 180)
GuiControl, Move, ConvertButton, % "x" . (A_GuiWidth - 160) . " y" . (A_GuiHeight - 40)
Return

Play:
GuiControl, Disable, PlayButton
GuiControlGet, Tune,, Tune
If InStr(Tune,"NotePlayer") ;input is code
{
    ;set instrument if present
    If RegExMatch(Tune,"iS)\w\.Instrument(\s*(\d+)\s*)",Value)
        GuiControl, Choose, Instrument, % Value1 + 1

    Notes := new NotePlayer ;create a noteplayer with the correct instrument
    Notes.Instrument(Value1)

    Loop, Parse, Tune, `n, %A_Space%%A_Tab%
    {
        If RegExMatch(A_LoopField,"iS)^\s*\w+((?:\.Note\(\s*\d+\s*(?:,\s*\d+\s*){1,3}\))*)\.Delay\(\s*(-?\d+(?:\.\d+)?)\s*\)",Field)
        {
            Field1 := SubStr(Field1,2) ;remove first dot
            Loop, Parse, Field1, . ;process each note
            {
                Value2 := "", Value3 := "", Value4 := ""
                RegExMatch(A_LoopField,"iS)^Note\(\s*(\d+)\s*(?:,\s*(\d+)\s*(?:,\s*(\d+)\s*(?:,\s*(\d+)\s*)?)?)?",Value)
                If (Value2 = "")
                    Notes.Note(Value1)
                Else If (Value3 = "")
                    Notes.Note(Value1,Value2)
                Else If (Value4 = "")
                    Notes.Note(Value1,Value2,Value3)
                Else
                    Notes.Note(Value1,Value2,Value3,Value4)
            }
            Notes.Delay(Field2)
        }
    }
}
Else
{
    GuiControlGet, Instrument,, Instrument ;retrieve the instrument index

    Notes := new NotePlayer ;create a noteplayer with the correct instrument
    Notes.Instrument(Instrument - 1)

    Loop, Parse, Tune, `n, %A_Space%%A_Tab%
    {
        If RegExMatch(A_LoopField,"iS)^\s*(-?\d+(?:\.\d+)?)\s*(.*)$",Field)
        {
            ;process chord
            StringReplace, Field2, Field2, %A_Tab%, %A_Space%, All ;replace tabs with spaces
            Field2 := Trim(Field2," ") ;trim spaces
            While, InStr(Field2,"  ") ;collapse spaces
                StringReplace, Field2, Field2, %A_Space%%A_Space%, %A_Space%, All
            Loop, Parse, Field2, %A_Space% ;process each note
                Notes.Note(NoteTable[A_LoopField],Field1)
            Notes.Delay(Field1)
        }
    }
}
Notes.Start()
While, Notes.Playing
    Sleep, 10
Notes.Device.__Delete(), Notes := ""
GuiControl, Enable, PlayButton
Return

Convert:
GuiControlGet, Tune,, Tune
If InStr(Tune,"NotePlayer") ;input is code
{
    ;set instrument if present
    If RegExMatch(Tune,"iS)\w\.Instrument(\s*(\d+)\s*)",Value)
        GuiControl, Choose, Instrument, % Value1 + 1

    Result := ""
    Loop, Parse, Tune, `n, %A_Space%%A_Tab%
    {
        If RegExMatch(A_LoopField,"iS)^\s*\w+((?:\.Note\(\s*\d+\s*(?:,\s*\d+\s*){1,3}\))*)\.Delay\(\s*(-?\d+(?:\.\d+)?)\s*\)",Field)
        {
            Result .= Field2 ;insert the duration
            Field1 := SubStr(Field1,2) ;remove first dot
            Loop, Parse, Field1, . ;process each note
            {
                RegExMatch(A_LoopField,"iS)^Note\(\s*\K\d+",Value)
                Result .= " " . NumberTable[Value] ;insert the note
            }
            Result .= "`n"
        }
    }
    Result := SubStr(Result,1,-1)
}
Else
{
    GuiControlGet, Instrument,, Instrument ;retrieve the instrument index

    ;extract the instrument name
    Position := InStr("`n" . Instruments,"`n",1,1,Instrument)
    Name := SubStr(Instruments,Position,InStr(Instruments . "`n","`n",1,Position) - Position)
    StringLower, Name, Name

    ;generate the code
    Result := "Notes := new NotePlayer`nNotes.Instrument(" . (Instrument - 1) . ") `;" . Name . "`n"
    Loop, Parse, Tune, `n, %A_Space%%A_Tab%
    {
        If RegExMatch(A_LoopField,"iS)^\s*(#|-?\d+(?:\.\d+)?)\s*(.*)$",Field)
        {
            If (Field1 = "#") ;comment
                Result .= ";" . Field2 . "`n"
            Else ;note chord
            {
                ;process chord
                Result .= "Notes"
                StringReplace, Field2, Field2, %A_Tab%, %A_Space%, All ;replace tabs with spaces
                Field2 := Trim(Field2," ") ;trim spaces
                While, InStr(Field2,"  ") ;collapse spaces
                    StringReplace, Field2, Field2, %A_Space%%A_Space%, %A_Space%, All
                Loop, Parse, Field2, %A_Space% ;process each note
                    Result .= ".Note(" . NoteTable[A_LoopField] . "," . Field1 . ")"
                Result .= ".Delay(" . Field1 . ")`n"
            }
        }
    }
    Result .= "Notes.Start()"
}
GuiControl,, Tune, %Result%
Return

#Include ../lib/Music.ahk