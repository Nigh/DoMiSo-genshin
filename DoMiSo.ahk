debug:=1
#NoEnv
SetWorkingDir %A_ScriptDir%
#Include data/midi_data.ahk
#Include lib/Music.ahk
#Include menu.ahk
#Include gui.ahk

pBitmap_Title:=Gdip_CreateBitmapFromFile(buttonpicDir  "title.png")
hdc:=GetDC(hTitle)
G := Gdip_GraphicsFromHDC(hdc)
Gdip_DrawImage(G, pBitmap_Title, 0, 0, 340, 30, 0, 0, 340, 30)

pBitmap%tabnum%_shijiao:=Gdip_CreateBitmapFromFile(buttonpicDir  "tab_shijiao.png")
OnMessage(0x86,"NCactivate")

/*
txt=
(
bpm=200
1=F
-6/ 5/. 6//-/ 3/- 2/ 1/ 3-- 0/ -6/ 5/. 6//- 3/- 2/ 5/ 3--
)
*/

baseOffset:=[0,2,4,5,7,9,11]

Notes := new NotePlayer(2)
Notes.Instrument(1)
Gosub, play
;~ Notes.Repeat := 1
;~ MsgBox, % txt
Return

#Include menu_label.ahk

play:
Gui, Submit, NoHide
txt:=editer
Gosub resolution
;~ If debug
;~ {
;~ MsgBox, % output
;~ Clipboard:=output
;~ }
Notes.Start()
Return

Exit:
ExitApp

winMove:
PostMessage, 0xA1, 2
Return

resolution:
output:=""
Notes.Reset()

base:=60
beatTime:=Round(60000/80)

Loop, Parse, txt, `n,%A_Space%%A_Tab%	;逐行解析
{
	chord:=0	;重置和弦标记
	chordTime:=0	;重置和弦长度
	
	If(RegExMatch(A_LoopField,"i)(?:b|B)(?:p|P)(?:m|M)=(\d+)",o))	;解析bpm标记
	{
		If(o1>0 And o1<480)	; make sure users won't do sth crazy...
		beatTime:=Round(60000/o1)
	}
;~ 	MsgBox, % NoteData
	If(RegExMatch(A_LoopField,"i)1=([A-G]\d?\d?\#?|b?)",p))	;解析调号标记
	{
		If(RegExMatch(NoteData,"(\d\d?\d?)\s" p1 "\s",q))
		base:=q1
	}
	
	If(RegExMatch(A_LoopField,"i)rollback=(\d+\.?\d*)",r))	;解析rollback标记
	{
;~ 		MsgBox, % "rollback=" r1 "`nOffset=" Notes.Offset
		If(r1*beatTime<=Notes.Offset)
		{
		Notes.Delay(-r1*beatTime)
		output.="Notes.Delay(" -r1*beatTime ")`n"
		}
		Else
		{
		Notes.Offset:=0
		output.="Notes.Offset:=0`n"
		}
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
		If(RegExMatch(A_LoopField,"iS)^(\-*|\+*)([0-7])(\#|b)?(\/*)((?:(?:\-\/*)|(?:\.))*)\s?$",tune))	;解析音符
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
			
;~ 			If(tune4!="")	;解析基本音符长度
			If(1)
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
;~ 							MsgBox, % noteTime "`n" timeIncrement
							timeIncrement:=timeIncrement>>1
;~ 							MsgBox, % timeIncrement
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
			If(noteTune>0 or chord=1)
			{
				If(!chord)
				{
				Notes.Note(noteTune,noteTime,50).Delay(noteTime)
				output.="Notes.Note(" noteTune "," noteTime ",50).Delay(" noteTime ")`n"
				}
				Else If(noteTune>0)
				{
					Notes.Note(noteTune,noteTime,50)
					chordTime:=noteTime>chordTime ? noteTime : chordTime
					output.="Notes.Note(" noteTune "," noteTime ",50)`n"
				}
			}
			Else
			{
				Notes.Delay(noteTime)
				output.="Notes.Delay(" noteTime ")`n"
			}
		}
		If(RegExMatch(A_LoopField,"iS)(\(|\))",mark))	;解析括号
		{
			If(mark1="(" And chord=0)
			chord:=1
			Else If(mark1=")" And chord=1)
			{
				Notes.Delay(chordTime)
				chord:=0
				output.="Notes.Delay(" chordTime ")`n"
			}
			
		}
	}
}

Return


NCactivate(wParam, lParam, msg, hwnd)
{
	global
	If(WinExist("A")=gui_id)
	{
	Gdip_DrawImage(G%tabnum%, pBitmap%tabnum%_up, 0, 0, 356, 30, 0, 0, 356, 30)
	Gdip_DrawImage(G%exitnum%, pBitmap%exitnum%_up, 0, 0, 34, 30, 0, 0, 34, 30)
	}
	Else
	{
	Gdip_DrawImage(G%tabnum%, pBitmap%tabnum%_shijiao, 0, 0, 356, 30, 0, 0, 356, 30)
	Gdip_DrawImage(G%exitnum%, pBitmap%exitnum%_over, 0, 0, 34, 30, 0, 0, 34, 30)
	}
}

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
