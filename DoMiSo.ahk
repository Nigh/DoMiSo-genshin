
debug:=0
#SingleInstance force
SetBatchLines, -1
SetWorkingDir %A_ScriptDir%
SetKeyDelay, 1, 1 
SendMode event 

#Include data/midi_data.ahk
#Include lib/Music.ahk
#Include menu.ahk

; q w e r t y u
; a s d f g h j
; z x c v b n m

hotkey_list:="qwertyuasdfghjzxcvbnm"
isBtn1Playing:=0
chord_keydown:=0
#Include gui.ahk
Return

titleMove:
PostMessage 0xA1, 2
Return

#Include menu_label.ahk

func_btn_play:
if(isBtn1Playing=0)
{
	Gosub, main_start
}
Else
{
	Gosub, main_stop
}
Return

func_btn_exit:
Exit:
ExitApp

winMove:
PostMessage, 0xA1, 2
Return

main_start:
Gosub, resolution
Gosub, hotkey_enable
WinActivate, ahk_exe YuanShen.exe
Return

main_stop:
Gosub, hotkey_disable
Return

key_scan:
_keydown:=0
Loop, Parse, hotkey_list
{
	_keydown+=GetKeyState(A_LoopField, "P")
}
chord_keydown:=_keydown
if(chord_key_wait_up)
{
	if not chord_keydown
	{
		genshin_play_p+=1
		SetTimer, key_scan, Off
		key_scan_enable:=0
		chord_key_wait_up:=0
	}
	Return
}
if(chord_keydown=StrLen(genshin_play_array[genshin_play_p]))
{
	chord_key_wait_up:=1
	SendInput, % genshin_play_array[genshin_play_p]
}
Return

note_key_down:
; 硬核模式下，追踪已按下的键的状态
; 确保按下和弦相同的按键数量后才发送按键
_thishotkey:=A_ThisHotkey
if (ishardcore=1) and StrLen(genshin_play_array[genshin_play_p])>1
{
	if not key_scan_enable
	{
		key_scan_enable:=1
		SetTimer, key_scan, 10
	}
}
Else
{
	SendInput, % genshin_play_array[genshin_play_p]
	genshin_play_p+=1
	KeyWait, % SubStr(_thishotkey, 0)
}
if(genshin_play_p > genshin_play_array.Length())
{
	; 演奏结束
	; 取消热键绑定
	Gosub, hotkey_disable
}
Return

hotkey_enable:
isBtn1Playing:=1
btn1update()
genshin_play_p := 1
Hotkey, IfWinActive, ahk_exe YuanShen.exe
Loop, Parse, hotkey_list
{
	Hotkey, % "$" A_LoopField, note_key_down, on
}
Return

hotkey_disable:
isBtn1Playing:=0
btn1update()
Loop, Parse, hotkey_list
{
	Hotkey, % A_LoopField, Off
}
Return

resolution:
Gui, submit, NoHide
ishardcore:=hardcore
StringLower, txt, editer
genshin_play_array:={}
chord:=0
Loop, Parse, txt, `n,%A_Space%%A_Tab%	;逐行解析
{
	currentLine:=A_LoopField
	Loop, Parse, currentLine, ,%A_Space%%A_Tab%
	{
		If(RegExMatch(A_LoopField,"iS)[qwertyuasdfghjzxcvbnm]",notes))	;解析音符
		{
			If chord=0
			{
				genshin_play_array.Push(notes)
			}
			Else
			{
				chord_buffer.=notes
			}
		}
		If(RegExMatch(A_LoopField,"iS)(\(|\))",mark))	;解析括号
		{
			If(mark1="(" And chord=0)
			{
				chord:=1
				chord_buffer:=""
			}
			Else If(mark1=")" And chord=1)
			{
				chord:=0
				genshin_play_array.Push(chord_buffer)
			}
		}
	}
}
Return

GuiClose:
ExitApp

#If debug
F5::ExitApp
F6::Reload
#If
F9::Gosub, main_start
F8::Gosub, main_stop

