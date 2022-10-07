
#Requires AutoHotkey v1.1.34
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
; #Warn  ; Enable warnings to assist with detecting common errors.
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.
#SingleInstance force
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%
SetKeyDelay, -1, -1 
SendMode event 
FileEncoding, UTF-8

#include meta.ahk

;@Ahk2Exe-IgnoreBegin
if A_Args.Length() > 0
{
	for n, param in A_Args
	{
		RegExMatch(param, "--out=(\w+)", outName)
		if(outName1=="version") {
			f := FileOpen(versionFilename,"w","UTF-8-RAW")
			f.Write(version)
			f.Close()
			ExitApp
		}
	}
}
;@Ahk2Exe-IgnoreEnd

;@Ahk2Exe-SetCompanyName HelloWorks
;@Ahk2Exe-SetName Domiso Genshin
;@Ahk2Exe-SetDescription Domiso Genshin
;@Ahk2Exe-SetVersion version
;@Ahk2Exe-SetMainIcon icon.ico
;@Ahk2Exe-ExeName Domiso-Genshin

IniRead, nonAdmin, setting.ini, update, nonAdminMode, 0
if(!nonAdmin){
	UAC()
}
;@Ahk2Exe-IgnoreBegin
	MsgBox, 0x41030,ATTENTION,You are running DEBUG version!!!`注意，正在运行的是测试版本。
;@Ahk2Exe-IgnoreEnd
if(betaBuild=1) {
	MsgBox, 0x41030,ATTENTION,You are running BETA version!!!`注意，正在运行的是内测版本。
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

_Instrument:=inst

DllCall("QueryPerformanceFrequency", "Int64P", freq)

baseOffset := [0,2,4,5,7,9,11]

; DONE: non admin & global mode display

Notes := new NotePlayer()
if(Notes.Device==0) {
	midi_device := False
} else {
	midi_device := True
}
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
IniRead, global_mode, setting.ini, setup, globalMode, 0

#Include gui.ahk
Gosub resolve
if(midi_device && startup_music){
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
	global genshin_note_map, total_beats
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
	statubar_txt(Round(Notes.total_beats,2) " beats | " genshinNotesCount "/" notesCount " Notes | " Round(100*genshinNotesCount/notesCount, 2) "% fits game")
}

genshin_main:
if(!global_mode) {
	genshin_win_hwnd:=genshin_window_exist()
}
if(genshin_play_p > genshin_play_array.Length() or (!global_mode && !genshin_win_hwnd))
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
	if(global_mode) {
		if WinActive("ahk_id " domiso_active_hwnd)
		{
			Send, % genshin_play_array[genshin_play_p].note
		}
	} else {
		if WinActive("ahk_id " genshin_win_hwnd)
		{
			Send, % genshin_play_array[genshin_play_p].note
		}
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
		if size >= 256
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
		Gosub, resolve
	}
}

genshin_play()
{
	global startTime, freq, genshin_play_p, isBtn1Playing, global_mode, domiso_active_hwnd, gui_id
	genshin_play_p := 1
	DllCall("QueryPerformanceCounter", "Int64P",  nowTime)
	domiso_active_hwnd:=0
	if(global_mode) {
		domiso_active_hwnd:=WinExist("A")
		if(domiso_active_hwnd == gui_id) {
			Return
		}
	} else {
		genshin_hwnd := genshin_window_active(genshin_window_exist())
		WinWaitActive, ahk_id %genshin_hwnd%,, 0
		if(ErrorLevel==1)
		{
			MsgBox, 0x41010,,Genshin is not running!!!
			Return
		}
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
if(global_mode){
	MsgBox, 0x41010, ERROR, USE Hotkey to play in global mode`n`n全局模式请使用热键开始演奏
	Return
}
func_hotkey_play:
if(nonAdmin)
{
	MsgBox, 0x41010, ERROR, Can not play in non Admin Mode`n`n在非管理员模式下无法自动演奏
	Return
}
if(!isBtn1Playing)
{
	Gosub resolve
	genshin_array_sort(genshin_play_array)
	if(midi_device) {
		Gosub, func_btn_listen_stop
	}
	genshin_play()
}
Return

no_midi_device_warning(){
	MsgBox, 0x41010, ERROR, Midi output Device not found`n`n没有找到可供试听的Midi设备
}

func_btn_listen_stop:
if(midi_device) {
	Notes.Reset()
	isBtn2Playing:=0
	btn2update()
} else {
	no_midi_device_warning()
}
Return

func_btn_listen:
if(midi_device) {
	if(!isBtn2Playing)
	{
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
} else {
	no_midi_device_warning()
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
Gui, main:Submit, NoHide
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
Gui, main:Submit, NoHide
_Instrument:=instrument_select-1
if(sheet_mode=="normal")
{
	sheet_content:=editer

}
parse_content:=sheet_content
if(sheet_mode="normal")
{
	If Encrypt_dms_valid(sheet_content)=1
	{
		parse_content:=dms_parser(sheet_content)[2]
	}
}

total_beats:=0
genshin_play_array:={}
genshin_output:=""
genshin_delay:=0

arpeggio_start:=0	;琶音起始
; TODO: 拍子计算直接修改为最后一个音符的结束时间/beatTime
; TODO: 增加设定琶音延时的语法
arpeggio_delay_set:=40	;琶音递增延时
arpeggio_delay:=0	;琶音累计延时

output:=""
Notes.Reset()
if(_Instrument<0 or _Instrument>127){
	_Instrument:=0
}
Notes.Instrument(_Instrument)
base:=60
beatTime:=Round(60000/80, 2)
Loop, Parse, parse_content, `n,`r%A_Space%%A_Tab%	;逐行解析
{
	chord:=0	;重置和弦标记
	chordTime:=0	;重置和弦长度
	multiplet:=0	;重置多连音标记
	this_chord_beats:=0
	
	If(RegExMatch(A_LoopField,"iO)(?:b|B)(?:p|P)(?:m|M)=(\d+)",o))	;解析bpm标记
	{
		bpm_parser(o)
	}
;~ 	MsgBox, % NoteData
	If(RegExMatch(A_LoopField,"iO)1=([A-G]\d?\d?\#?|b?)",p))	;解析调号标记
	{
		tone_parser(p)
	}
	
	If(RegExMatch(A_LoopField,"iO)rollback=(\d+\.?\d*)",r))	;解析rollback标记
	{
		rollback_parser(r)
	}
	
	/*
	琶音 arpeggio
	音阶 scale
	音符 note
	升降调 semitone
	时值 notelen
	*/
	
	currentLine:=A_LoopField
	Loop, Parse, currentLine, %A_Space%%A_Tab%
	{
		If(RegExMatch(A_LoopField,"iSO)^(?P<arpeggio>\~)?(?P<scale>\-*|\+*)(?P<note>[0-7])(?P<semitone>\#|b)?(?P<notelen>(?:\/|\-|\.)*)\s?$",tune))	;解析音符
		{
			note_parser(tune)
		}
		If(RegExMatch(A_LoopField,"iSO)(\(|\{)",mark))	;解析左括号
		{
			bracket_start_parser(mark)
		}
		If(RegExMatch(A_LoopField,"iSO)(\)|\})((?:\/|\-|\.)*)\s?$",mark))	;解析右括号
		{
			bracket_end_parser(mark)
		}
	}
}
Notes.total_beats:=total_beats
; Clipboard:=genshin_output
; 统计音符并显示到状态栏
analyseNotes(Notes)
Return

bpm_parser(obj)
{
	global
	If(o.Value(1)>30 And o.Value(1)<600)
	beatTime:=Round(60000/o.Value(1), 2)
}

tone_parser(obj)
{
	global
	If(RegExMatch(NoteData,"(\d\d?\d?)\s" obj.Value(1) "\s",q))
	base:=q1	
}

rollback_parser(obj)
{
	global
	If(obj.Value(1)*beatTime<=Notes.Offset)
	{
		Notes.Delay(-obj.Value(1)*beatTime)
		output.="Notes.Delay(" -obj.Value(1)*beatTime ")`n"
		genshin_delay -= obj.Value(1)*beatTime
	}
	Else
	{
		Notes.Offset:=0
		output.="Notes.Offset:=0`n"
		genshin_delay := 0
	}
}

note_parser(tune)
{
	global
	noteTime:=beatTime
	
	If(tune.Value("scale")!="")	;解析八度偏移量
	{
		If InStr(tune.Value("scale"), "-")
		offs:=-StrLen(tune.Value("scale"))
		Else If InStr(tune.Value("scale"), "+")
		offs:=StrLen(tune.Value("scale"))
		Else offs:=0
	}
	Else offs:=0
	
	noteTune:=base+baseOffset[tune.Value("note")+0]+offs*12	;解析基本音
	
	If(tune.Value("semitone")!="")	;解析升降调
	{
		If InStr(tune.Value("semitone"), "#"){
			noteTune+=1
		}
		Else If InStr(tune.Value("semitone"), "b"){
			noteTune-=1
		}
	}

;~ 			If(tune.Value(4)!="")	;解析基本音符长度
	If(1)
	{
		noteTime:=extra_length_parser(beatTime, tune.Value("notelen"))
		this_note_beats:=noteTime/beatTime
	}
	if(chord=1) {
		if(noteTune>0) {
			chord_cache.Push({"note":noteTune,"time":noteTime})
			chordTime:=noteTime>chordTime ? noteTime : chordTime
		}
	} else if(multiplet=1) {
		multiplet_cache.Push({"note":noteTune,"time":noteTime})
	} else {
		If(tune.Value("arpeggio")!="")	;解析琶音标记
		{
			if(noteTime<=arpeggio_delay+20) {
				Return
			}
			Notes.Delay(-last_noteTime)
			Notes.Delay(arpeggio_delay_set)
			genshin_delay+=arpeggio_delay_set-last_noteTime
			arpeggio_delay+=arpeggio_delay_set
			noteTime-=arpeggio_delay
		} else {
			arpeggio_start:=genshin_delay
			arpeggio_delay:=0
		}
		if(noteTune>0) {
			Notes.Note(noteTune,noteTime,50).Delay(noteTime)
			output.="Notes.Note(" noteTune "," noteTime ",50).Delay(" noteTime ")`n"
			genshin_output.="[" Round(genshin_delay) "]-(" genshin_note_map[noteTune] ")`n"
			genshin_play_array.Push({"delay":Round(genshin_delay),"note":genshin_note_map[noteTune]})
			genshin_delay += noteTime
			total_beats += this_note_beats
		} else {
			Notes.Delay(noteTime)
			output.="Notes.Delay(" noteTime ")`n"
			genshin_delay += noteTime
			total_beats += this_note_beats
		}
	}
	last_noteTime:=noteTime
}

bracket_start_parser(obj)
{
	global
	If(mark.Value(1)="(" And chord=0)
	{
		chord:=1
		chord_cache:={}
		chordTime:=0
		this_chord_beats:=0
	}
	If(mark.Value(1)="{" And multiplet=0)
	{
		multiplet:=1
		multiplet_cache:={}
	}
}
; 解析额外长度标记
extra_length_parser(basetime, src)
{
	global beatTime
	s := 1
	p := RegExMatch(src, "iO)(\/|\-|\.+)", obj, s)
	while(p)
	{
		if(obj.Value(1)="/")
		{
			basetime /= 2
		} else if(obj.Value(1)="-") {
			basetime += beatTime
		} else {
			db:=basetime
			Loop, % obj.Len(1)
			{
				db *= 0.5
				basetime += db
			}
		}
		s += obj.Len(1)
		p := RegExMatch(src, "iO)(\/|\-|\.+)", obj, s)
	}
	return basetime
}
bracket_end_parser(mark)
{
	global
	local d,p,s,obj,db,mlen,mk,mtime
	If(mark.Value(1)=")" And chord=1)
	{
		chord:=0
		if(mark.Value(2)!="")
		{
			chordTime := extra_length_parser(chordTime, mark.Value(2))
		}
		Loop, % chord_cache.Length()
		{
			Notes.Note(chord_cache[A_Index].note, chordTime, 50)
			; chord_cache[A_Index].time
			output.="Notes.Note(" chord_cache[A_Index].note "," chordTime ",50)`n"
			genshin_output.="[" Round(genshin_delay) "]-(" genshin_note_map[chord_cache[A_Index].note] ")`n"
			genshin_play_array.Push({"delay":Round(genshin_delay),"note":genshin_note_map[chord_cache[A_Index].note]})
		}
		Notes.Delay(chordTime)
		chord:=0
		output.="Notes.Delay(" chordTime ")`n"
		genshin_delay += chordTime
		this_chord_beats := chordTime/beatTime
		total_beats += this_chord_beats
	}
	If(mark.Value(1)="}" And multiplet=1)
	{
		multiplet:=0
		mtime:=beatTime
		if(mark.Value(2)!="")
		{
			mtime := extra_length_parser(mtime, mark.Value(2))
		}
		mlen:=0
		Loop, % multiplet_cache.Length()
		{
			mlen+=multiplet_cache[A_Index].time
		}
		mk:=mtime/mlen
		Loop, % multiplet_cache.Length()
		{
			if(multiplet_cache[A_Index].note > 0) {
				Notes.Note(multiplet_cache[A_Index].note, mk*multiplet_cache[A_Index].time, 50)
			}
			Notes.Delay(mk*multiplet_cache[A_Index].time)
			output.="Notes.Note(" multiplet_cache[A_Index].note "," mk*multiplet_cache[A_Index].time ",50)`n"
			genshin_output.="[" Round(genshin_delay) "]-(" genshin_note_map[multiplet_cache[A_Index].note] ")`n"
			genshin_play_array.Push({"delay":Round(genshin_delay),"note":genshin_note_map[multiplet_cache[A_Index].note]})
			genshin_delay+=mk*multiplet_cache[A_Index].time
		}
		total_beats += mtime/beatTime
	}
}

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

free(ByRef var)
{
	VarSetCapacity(var, 0)
}

GuiClose:
ExitApp

TrueExit:
IniWrite, % _Instrument, setting.ini, update, inst
IniWrite, % version, setting.ini, update, ver
log_flush()
ExitApp

;@Ahk2Exe-IgnoreBegin
F5::ExitApp
F6::Reload
;@Ahk2Exe-IgnoreEnd

F8::genshin_stop()
F9::Gosub, func_hotkey_play

#include menu.ahk
