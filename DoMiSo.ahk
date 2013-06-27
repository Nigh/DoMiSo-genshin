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
-5/ -6/ 1 2--/ 3// 2// 1/-// -6// 3-
0/ -5/ -6/ 1/ 2-- 3// 2// 1/-// 5//- 3/-
)

base:=60
baseOffset:=[0,2,4,5,7,9,11]

Notes := new NotePlayer
Notes.Instrument(1)
;~ Notes.Repeat := 1
;~ MsgBox, % txt
Gosub resolution

Notes.Start()

Return


resolution:
Loop, Parse, txt, `n,%A_Space%%A_Tab%	;逐行解析
{
	RegExMatch(A_LoopField,"i)(?:b|B)(?:p|P)(?:m|M)=(\d+)",o)	;解析bpm标记
	If(o1>0 And o1<480)	; make sure users won't do sth crazy...
	beatTime:=Round(60000/bpm)
	Else
	beatTime:=Round(60000/80)
	
	If(RegExMatch(A_LoopField,"i)1=([A-G]\#?\b?)",p))	;解析调号标记
	{
		RegExMatch(NoteData,"i)(\d+)\s" p1,q)
		base:=q1
	}
	
	/*
	tune1:音阶
	tune2:音符
	tune3:升降调
	tune4:本音长
	tune5:延音长
	*/
	currentLine:=A_LoopField
	Loop, Parse, currentLine, %A_Space%%A_Tab%
	{
		If(RegExMatch(A_LoopField,"iS)(\-*|\+*)([0-7])(\#|b)?(\/*)((?:(?:\-\/*)|(?:\.))*)\s?$",tune))	;解析音符
		{
			noteTime:=beatTime
			
			If(tune1!="")	;解析八度偏移量
			{
				If InStr(tune1, "-")
				offs:=-StrLen(tune1)
				Else If InStr(tune1, "+")
				offs:=StrLen(tune1)
				Else offs:=0
			}
			Else offs:=0
			
			noteTune:=base+baseOffset[tune2]+offs*12	;解析基本音
			
			If(tune3!="")	;解析升降调
			{
				If InStr(tune3, "#"){
					noteTune+=1
				}
				
				Else If InStr(tune3, "b"){
					noteTune-=1
				}
			}
			
			If(tune4!="")	;解析音符长度
			{
				noteTime:=beatTime>>StrLen(tune4)
				timeIncrement:=noteTime
			}
			
			If(tune5!="")	;解析延音长度
			{
				RegExMatch(tune5,"((?:\-\/*)|(?:\.))((?:\-\/*)|(?:\.))?((?:\-\/*)|(?:\.))?((?:\-\/*)|(?:\.))?((?:\-\/*)|(?:\.))?((?:\-\/*)|(?:\.))?((?:\-\/*)|(?:\.))?((?:\-\/*)|(?:\.))?((?:\-\/*)|(?:\.))?",tmp)
				Loop
				{
					If(tmp%A_Index%!="")
					{
						If InStr(tmp%A_Index%,".")
						{
						timeIncrement:=timeIncrement>>1
						noteTime+=timeIncrement
						}
						Else
						{
							timeIncrement:=beatTime>>(StrLen(tmp%A_Index%)-1)
							noteTime+=timeIncrement
						}
					}
					Else
					Break
				}
		}
		If(noteTune>0)
		{
		Notes.Note(noteTune,noteTime,50).Delay(noteTime)
		output.="Notes.Note(" noteTune "," noteTime ",50).Delay(" noteTime ")`n"
		}
		Else
		{
		Notes.Delay(noteTime)
		output.="Notes.Delay(" noteTime ")`n"
		}
		}
	}
}

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
