
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%
SetKeyDelay, 1, 1 
SendMode event 
FileEncoding, UTF-8

outputVersion()
if A_IsCompiled
debug:=0
Else
debug:=1

debugHotkey:=debug
; debugHotkey:=0
IniRead, nonAdmin, setting.ini, update, nonAdminMode, 0
if(!nonAdmin){
	UAC()
}
if debug
{
	MsgBox, 0x41030,ATTENTION,You are running DEBUG version of the program!!!
}

OnExit, TrueExit
#Include log.ahk
log_init()

#include update.ahk

#Include data/midi_data.ahk
#Include lib/Music.ahk
#include Encrypt.ahk

menu()

; 谱面模式normal or cipher
sheet_mode:="normal"
; 谱面内容
sheet_content:=""
; 显示内容
plain_content:=""


isBtn1Playing:=0
isBtn2Playing:=0

_Instrument:=10
DllCall("QueryPerformanceFrequency", "Int64P", freq)

baseOffset := [0,2,4,5,7,9,11]

; TODO: add no midi mode

Notes := new NotePlayer()
Notes.Instrument(_Instrument)
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

IniRead, startup_music, setting.ini, update, startupMusic, 1
IniRead, clean_start, setting.ini, update, startupEditorClean, 0

#Include gui.ahk
Gui, Submit, NoHide
sheet_content:=editer
Gosub resolve
if(startup_music){
	Notes.Start()
}
Return

titleMove:
PostMessage 0xA1, 2
Return

genshin_array_sort(ByRef array)
{
	array_string:=""
	For index, v in array
	{
		array_string .= v.delay "," v.note "`n"
	}
	Sort, array_string, N
	array:={}
	Loop, Parse, array_string, `n
	{
		if(RegExMatch(A_LoopField, "O)(\d+),(\w)", note))
		{
			array.Push({"delay":note[1], "note":note[2]})
		}
	}
}

analyseNotes(Notes)
{
	global genshin_note_map
	notesCount:=0
	genshinNotesCount:=0
	For Key, Array in Notes.Timeline
	{
		For k, v in Array
		{
			if(v.Type=="NoteOn") {
				notesCount+=1
				if(genshin_note_map.HasKey(v.Index)){
					genshinNotesCount+=1
				}
			}
		}
	}
	statubar_txt(genshinNotesCount "/" notesCount " Notes | " Round(100*genshinNotesCount/notesCount, 2) "% playable in game")
}

genshin_main:
genshin_win_hwnd:=genshin_window_exist()
if((genshin_play_p > genshin_play_array.Length()) or (!genshin_win_hwnd))
{
	isBtn1Playing:=0
	btn1update()
	SetTimer, genshin_main, Off
	Return
}
DllCall("QueryPerformanceCounter", "Int64P",  nowTime)
; genshin_window_active(genshin_window_exist())
While(nowTime//(freq/1000)-startTime >= genshin_play_array[genshin_play_p].delay)
{
	if not genshin_play_array[genshin_play_p].note
	{
		Return
	}
	if WinActive("ahk_id " genshin_win_hwnd)
	{
		Send, % genshin_play_array[genshin_play_p].note
	}
	; ControlSend, ,% genshin_play_array[genshin_play_p].note, ahk_exe GenshinImpact.exe
	genshin_play_p += 1
}
Return

; 管理员权限下，无法直接使用拖入文件的功能，改由文件选择器调用此方法
GuiDropFiles(GuiHwnd, FileArray, CtrlHwnd, X, Y) {
	global hEdit1, editer, sheet_mode, plain_content, sheet_content
	if FileArray.MaxIndex() > 1
	{
		MsgBox, 0x41010, ERROR, More than 1 file detected.
		Return
	}
	if CtrlHwnd+0=hEdit1+0
	{
		FileGetSize, size, % FileArray[1], K
		if size >= 64
		{
			MsgBox, 0x41010, ERROR, The file is too LARGE.
			Return
		}
		f:=FileOpen(FileArray[1], "r")
		if(is_dms_file(f))
		{
			sheet_mode:="cipher"
			GuiControl, +ReadOnly +Disabled, editer
			f.Seek(0)
			_temp:=Decrypt_file(f)
			plain_content:=_temp[1]
			sheet_content:=_temp[2]
		}
		Else
		{
			sheet_mode:="normal"
			GuiControl, -ReadOnly -Disabled, editer
			f.Seek(0)
			plain_content:=f.Read()
			sheet_content:=plain_content
		}
		f.Close()
		ControlSetText,, % plain_content, ahk_id %hEdit1%
	}
}

genshin_play()
{
	global startTime, freq, genshin_play_p, isBtn1Playing
	genshin_play_p := 1
	DllCall("QueryPerformanceCounter", "Int64P",  nowTime)
	genshin_hwnd := genshin_window_active(genshin_window_exist())
	WinWaitActive, ahk_id %genshin_hwnd%,, 0
	if(ErrorLevel==1)
	{
		MsgBox, 0x41010,,Genshin is not running!!!
		Return
	}
	isBtn1Playing:=1
	btn1update()
	startTime:=nowTime//(freq/1000) + 500
	SetTimer, genshin_main, 5 
}

genshin_stop()
{
	global
	isBtn1Playing:=0
	btn1update()
	SetTimer, genshin_main, Off
}

genshin_window_exist()
{
	genshinHwnd := WinExist("ahk_exe GenshinImpact.exe")
	if not genshinHwnd
	{
		genshinHwnd := WinExist("ahk_exe YuanShen.exe")
	}
	return genshinHwnd
}

genshin_window_active(hwnd)
{
	WinActivate, ahk_id %hwnd%
	Return hwnd
}


func_btn_play:
if(nonAdmin)
{
	MsgBox, 0x41010, ERROR, Can not play in nonAdminMode
	Return
}
if(!isBtn1Playing)
{
	if(sheet_mode=="normal")
	{
		Gui, Submit, NoHide
		sheet_content:=editer
	}
	Gosub resolve
	genshin_array_sort(genshin_play_array)
	Gosub, func_btn_listen_stop
	genshin_play()
}
Return

func_btn_listen_stop:
	Notes.Reset()
	isBtn2Playing:=0
	btn2update()
Return

func_btn_listen:
if(!isBtn2Playing)
{
	if(sheet_mode=="normal")
	{
		Gui, Submit, NoHide
		sheet_content:=editer
	}
	Gosub resolve
	; Clipboard:=output
	Notes.Start()
	SetTimer, midi_playing_check, 1000
	isBtn2Playing:=1
	btn2update()
}
Else
{
	Gosub, func_btn_listen_stop
}
Return

midi_playing_check:
if(isBtn2Playing){
	if(!Notes.Playing){
		isBtn2Playing:=0
		btn2update()
		SetTimer, midi_playing_check, Off
	}
} else {
	SetTimer, midi_playing_check, Off
}
Return

func_btn_file:
Thread, NoTimers
FileSelectFile, select_file, 1, , Title, DoMiSo Sheet (*.txt; *.dms)
Thread, NoTimers, false
if select_file
{
	GuiDropFiles(0, [select_file], hEdit1, 0, 0)
}
Return

func_btn_publish:
if(sheet_mode!="normal")
{
	Return
}
Gui, Submit, NoHide
pub_txt:=editer
If Encrypt_dms_valid(pub_txt)!=1
{
	MsgBox, 0x41010, Wrong, No Publish Mark detected.
	Return
}
pub_filename:=Encrypt_dms_enc(pub_txt)
MsgBox, 0x1040, Success, % "Published as 【" pub_filename "】"
Return

func_btn_exit:
Exit:
ExitApp

winMove:
PostMessage, 0xA1, 2
Return

resolve:
parse_content:=sheet_content
if(sheet_mode="normal")
{
	If Encrypt_dms_valid(sheet_content)=1
	{
		parse_content:=dms_parser(sheet_content)[2]
	}
}

genshin_play_array:={}
genshin_output:=""
genshin_delay:=0

output:=""
Notes.Reset()
Notes.Instrument(_Instrument)
base:=60
beatTime:=Round(60000/80)
Loop, Parse, parse_content, `n,`r%A_Space%%A_Tab%	;逐行解析
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
		Else
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
			
			noteTune:=base+baseOffset[tune2+0]+offs*12	;解析基本音
			
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
					genshin_output.="[" genshin_delay "]-(" genshin_note_map[noteTune] ")`n"
					genshin_play_array.Push({"delay":genshin_delay,"note":genshin_note_map[noteTune]})
					genshin_delay += noteTime
				}
				Else If(noteTune>0)
				{
					Notes.Note(noteTune,noteTime,50)
					chordTime:=noteTime>chordTime ? noteTime : chordTime
					output.="Notes.Note(" noteTune "," noteTime ",50)`n"
					genshin_output.="[" genshin_delay "]-(" genshin_note_map[noteTune] ")`n"
					genshin_play_array.Push({"delay":genshin_delay,"note":genshin_note_map[noteTune]})
				}
			}
			Else
			{
				Notes.Delay(noteTime)
				output.="Notes.Delay(" noteTime ")`n"
				genshin_delay += noteTime
			}
		}
		If(RegExMatch(A_LoopField,"iS)(\(|\))",mark))	;解析括号
		{
			If(mark1="(" And chord=0)
			{
				chord:=1
				chordTime:=0
			}
			Else If(mark1=")" And chord=1)
			{
				Notes.Delay(chordTime)
				chord:=0
				output.="Notes.Delay(" chordTime ")`n"
				genshin_delay += chordTime
			}
		}
	}
}
; 统计音符并显示到状态栏
analyseNotes(Notes)
Return

UAC()
{
	full_command_line := DllCall("GetCommandLine", "str")
	if not (A_IsAdmin or RegExMatch(full_command_line, " /restart(?!\S)"))
	{
		try
		{
			if A_IsCompiled
				Run *RunAs "%A_ScriptFullPath%" /restart
			else
				Run *RunAs "%A_AhkPath%" /restart "%A_ScriptFullPath%"
		}
		ExitApp
	}
}

GuiClose:
ExitApp

TrueExit:
log_flush()
ExitApp

#If debugHotkey
F5::ExitApp
F6::Reload
#If
F8::genshin_stop()
F9::Gosub, func_btn_play

#include menu.ahk
