debug:=1
#NoEnv
SetWorkingDir %A_ScriptDir%
#Include midi_data.ahk
#Include lib/Music.ahk
#Include Gui.ahk

txt=
(
bpm=120
1=F#
-5---/ -6 1 2--/ 3// 2/ 1/-// -6// 3-
0/ -5/ -6/ 1/ 2-- 3 2 1/-// 5//- 3/-
)

;~ MsgBox, % txt
Gosub resolution

base:=60
baseOffset:=[0,2,4,5,7,9,11]

Notes := new NotePlayer
Notes.Instrument(0)
Notes.Repeat := 1

;~ Notes.Delay(1000)

Notes.Note(notez(1,0),300,80).Delay(250)
Notes.Note(notez(2,0),300,50).Delay(250)
Notes.Note(notez(3,0),300,50).Delay(250)
Notes.Note(notez(4,0),300,50).Delay(250)
Notes.Note(notez(5,0),300,80).Delay(250)
Notes.Note(notez(6,0),300,50).Delay(250)
Notes.Note(notez(7,0),300,50).Delay(250)
Notes.Note(notez(1,1),300,50).Delay(250)
Notes.Start()
Return


resolution:
;~ Loop, Parse, txt, `n
RegExMatch(txt,"i)(?:b|B)(?:p|P)(?:m|M)=(\d+)",o)
If(o1>0 And o1<500)	; make sure users won't do sth crazy...
beatTime:=Round(60000/bpm)
Else
beatTime:=Round(60000/80)

base:=60
RegExMatch(txt,"i)1=([A-G]\#?\-?)",p)
If(p1!="")
{
	RegExMatch(NoteData,"i)(\d+)\s" p1,q)
	base:=q1
}
RegExMatch(txt,"iS)(\-*|\+*)([1-7])(\#|b)?(\/*)((?:\-\/*)*)\s",tune)
/*
tune1:音阶
tune2:音符
tune3:升降调
tune4:本音长
tune5:延音长
*/
MsgBox, % tune5
Return

Callout(Match, CalloutNumber, FoundPos, Haystack, NeedleRegEx)
{
	MsgBox, % Match "`n" FoundPos
}

notez(n,offs=0)
{
	global
	Return, base+baseOffset[n]+offs*12
}

GuiClose:
ExitApp

#If debug
F5::ExitApp
#If
