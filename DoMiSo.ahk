﻿
debug:=0
#SingleInstance force
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%
SetKeyDelay, 1, 1
SendMode event

#Include data/midi_data.ahk
#Include lib/Music.ahk
#Include Menu.ahk

isBtn1Playing:=false
isBtn2Playing:=false

_Instrument:=10
DllCall("QueryPerformanceFrequency", "Int64P", freq)

baseOffset := [0,2,4,5,7,9,11]

Notes := new NotePlayer()
Notes.Instrument(_Instrument)
;~ Gosub, play
;~ Notes.Repeat := 1
;~ MsgBox, % txt
; q w e r t y u
; a s d f g h j
; z x c v b n m
genshin_note_map := { 48:"z"
										, 50:"x"
										, 52:"c"
										, 53:"v"
										, 55:"b"
										, 57:"n"
										, 59:"m"
										, 60:"a"
										, 62:"s"
										, 64:"d"
										, 65:"f"
										, 67:"g"
										, 69:"h"
										, 71:"j"
										, 72:"q"
										, 74:"w"
										, 76:"e"
										, 77:"r"
										, 79:"t"
										, 81:"y"
										, 83:"u" }
#Include Gui.ahk
Gui, Submit, NoHide
txt:=Editer
gosub resolution
Notes.Start()
return

GuiDropFiles:
	Loop, Parse, A_GuiEvent, `n
	{
		FileRead, OutputVar, %A_LoopField%
		GuiControl, , Editer, %OutputVar%
		break
	}
return

#Include Menu_label.ahk

genshin_array_sort(ByRef array)
{
	array_string:=""
	For index, v in array
	{
		array_string .= v.delay "," v.note "`n"
	}
	Sort, array_string, N
	array:={}
	loop, Parse, array_string, `n
	{
		if(RegExMatch(A_LoopField, "O)(\d+),(\w)", note))
		{
			array.Push({"delay":note[1], "note":note[2]})
		}
	}
	; MsgBox, % array_string
}

genshin_main:
	if(genshin_play_p > genshin_play_array.Length())
	{
		isBtn1Playing:=false
		btn1update()
		SetTimer, genshin_main, Off
		return
	}
	DllCall("QueryPerformanceCounter", "Int64P",  nowTime)
	IfWinNotActive, ahk_exe YuanShen.exe
	WinActivate, ahk_exe YuanShen.exe
	While(nowTime//(freq/1000)-startTime >= genshin_play_array[genshin_play_p].delay)
	{
		Send, % genshin_play_array[genshin_play_p].note
		; ControlSend, ,% genshin_play_array[genshin_play_p].note, ahk_exe YuanShen.exe
		genshin_play_p += 1
	}
return

genshin_play()
{
	global startTime, freq, genshin_play_p
	genshin_play_p := 1
	DllCall("QueryPerformanceCounter", "Int64P",  nowTime)
	WinActivate, ahk_exe YuanShen.exe
	WinWaitActive, ahk_exe YuanShen.exe,, 0
	if(ErrorLevel==1)
	{
		MsgBox, Genshin is not Running!!!
		return
	}
	isBtn1Playing:=true
	btn1update()
	startTime:=nowTime//(freq/1000) + 500
	SetTimer, genshin_main, 5
}

genshin_stop()
{
	isBtn1Playing:=false
	btn1update()
	SetTimer, genshin_main, Off
}

func_btn_play:
	if(!isBtn1Playing)
	{
		Gui, Submit, NoHide
		txt:=Editer
		gosub resolution
		genshin_array_Sort(genshin_play_array)
		gosub, func_btn_try_stop
		genshin_play()
	}
	else
	{
		genshin_stop()
	}
return

func_btn_try_stop:
	Notes.Reset()
	isBtn2Playing:=false
	btn2update()
return

func_btn_try:
	if(!isBtn2Playing)
	{
		Gui, Submit, NoHide
		txt:=Editer
		gosub resolution
		Notes.Start()
		isBtn2Playing:=true
		btn2update()
	}
	else
	{
		gosub, func_btn_try_stop
	}
return

func_btn_exit:
Exit:
	ExitApp

winMove:
	PostMessage, 0xA1, 2
return

resolution:
	genshin_play_array:={}
	genshin_output:=""
	genshin_delay:=0

	output:=""
	Notes.Reset()
	Notes.Instrument(_Instrument)
	base:=60
	beatTime:=Round(60000/80)

	loop, Parse, txt, `n,%A_Space%%A_Tab%	;逐行解析
	{
		chord:=0	;重置和弦标记
		chordTime:=0	;重置和弦长度

		If(RegExMatch(A_LoopField,"i)(?:b|B)(?:p|P)(?:m|M)=(\d+)",o))	;解析bpm标记
		{
			If(o1>0 And o1<480)
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
				genshin_delay -= r1*beatTime
			}
			else
			{
				Notes.Offset:=0
				output.="Notes.Offset:=0`n"
				genshin_delay := 0
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
		loop, Parse, currentLine, %A_Space%%A_Tab%
		{
			If(RegExMatch(A_LoopField,"iS)^(\-*|\+*)([0-7])(\#|b)?(\/*)((?:(?:\-\/*)|(?:\.))*)\s?$",tune))	;解析音符
			{
				noteTime:=beatTime

				If(tune1!="")	;解析八度偏移量
				{
					if InStr(tune1, "-")
						offs:=-StrLen(tune1)
					else if InStr(tune1, "+")
						offs:=StrLen(tune1)
					else offs:=0
				}
				else offs:=0

				noteTune:=base+baseOffset[tune2+0]+offs*12	;解析基本音

				If(tune3!="")	;解析升降调
				{
					if InStr(tune3, "#"){
						noteTune+=1
					}
					else if InStr(tune3, "b"){
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
					loop
					{
						If(tmp%A_Index%!="")
						{
							if InStr(tmp%A_Index%,".")
							{
								;~ 							MsgBox, % noteTime "`n" timeIncrement
								timeIncrement:=timeIncrement>>1
								;~ 							MsgBox, % timeIncrement
								noteTime+=timeIncrement
							}
							else
							{
								timeIncrement:=beatTime>>(StrLen(tmp%A_Index%)-1)
								noteTime+=timeIncrement
							}
						}
						else
							break
					}
				}
				If(noteTune>0 or chord=1)
				{
					If(!chord)
					{
						Notes.Note(noteTune,noteTime,50).Delay(noteTime)
						output.="Notes.Note(" noteTune "," noteTime ",50).Delay(" noteTime ")`n"
						genshin_output.="[" genshin_delay "]-(" genshin_note_map[noteTune] ")`n"
						genshin_play_array.Push({"delay":genshin_delay,"note":genshin_note_map[noteTune]})
						genshin_delay += noteTime
					}
					else if(noteTune>0)
					{
						Notes.Note(noteTune,noteTime,50)
						chordTime:=noteTime>chordTime ? noteTime : chordTime
						output.="Notes.Note(" noteTune "," noteTime ",50)`n"
						genshin_output.="[" genshin_delay "]-(" genshin_note_map[noteTune] ")`n"
						genshin_play_array.Push({"delay":genshin_delay,"note":genshin_note_map[noteTune]})
					}
				}
				else
				{
					Notes.Delay(noteTime)
					output.="Notes.Delay(" noteTime ")`n"
					genshin_delay += noteTime
				}
			}
			If(RegExMatch(A_LoopField,"iS)(\(|\))",mark))	;解析括号
			{
				If(mark1="(" And chord=0)
				chord:=1
				else if(mark1=")" And chord=1)
				{
					Notes.Delay(chordTime)
					chord:=0
					output.="Notes.Delay(" chordTime ")`n"
					genshin_delay += chordTime
				}
			}
		}
	}
return

GuiClose:
	ExitApp
return

#If debug
F5::ExitApp
F6::Reload
F7::
	genshin_play()
	WinActivate, ahk_exe YuanShen.exe
return
#If
F8::genshin_stop()
