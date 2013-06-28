;~ guiDebug:=1
pToken := Gdip_Startup()
Gui, -Caption +ToolWindow +AlwaysOnTop hwndgui_id
Gui, Color, ffffff, ffffff
Gui, Font, s20, OKTOBER
Gui, Add, Text, y40 w100 h30 hwndhTitle, ;DoMiSo
Gui, Font, s14, Zpix C.O.D.E
Gui, Add, Edit, w240 r12 vediter hwndhEdit1, 1=G`nbpm=120`n1 3 5 ( 1 3 5 )
;~ Gui, Add, Button, w100 hwndhButton1 +0xE, BUTTON
Gui, Show, AutoSize
buttonpicDir:="button\"
addPicButton("play","w100 h30",buttonpicDir "b2_up.png",buttonpicDir "b2_over.png",buttonpicDir "b2_down.png")
addPicButton("exit","xp+140 yp w100 h30",buttonpicDir "b1_up.png",buttonpicDir "b1_over.png",buttonpicDir "b1_down.png")
addPicButton("exit","x270 y0 w20 h19",buttonpicDir "x_up.png",buttonpicDir "x_over.png",buttonpicDir "x_down.png")
tabnum:=addPicButton("winMove","x0 y0 w270 h19 gwinMove",buttonpicDir "tab_up.png",buttonpicDir "tab_over.png",buttonpicDir "tab_over.png")
Gui, Show, w290

OnMessage(0x200, "MouseMove")
OnMessage(0x201, "MouseDown")
OnMessage(0x203, "MouseDown")
OnMessage(0x202, "MouseUp")

;~ OnMessage(0x202, "MouseLeave")
;~ OnMessage(0x2A3, "MouseLeave")
;~ hBitmap1:=Gdip_CreateHBITMAPFromBitmap(pBitmap1)

MouseUp(wParam, lParam, msg, hwnd)
{
	global
	local mhwnd
	MouseGetPos,,,,mhwnd,2
	MouseUpHwnd:=mhwnd
;~ 	MsgBox, Mouse Up %mhwnd%.
	If(mhwnd)
	{
		Loop, % buttons["max"]
		{
			If(mhwnd = hButton%A_Index%)
			Gdip_DrawImage(G%A_Index%, pBitmap%A_Index%_over, 0, 0, buttons[A_Index]["w"], buttons[A_Index]["h"], 0, 0, buttons[A_Index]["w"], buttons[A_Index]["h"])
		}
		If(MouseUpHwnd=MouseDownHwnd)
		{
			If(events[MouseUpHwnd]!="")
			Gosub, % events[MouseUpHwnd]
		}
		
	}
	Return
}

MouseDown(wParam, lParam, msg, hwnd)
{
	global
	local mhwnd
	MouseGetPos,,,,mhwnd,2
	MouseDownHwnd:=mhwnd
;~ 	MsgBox, Mouse Down %mhwnd%.
	If(mhwnd)
	Loop, % buttons["max"]
	{
		If(mhwnd = hButton%A_Index%)
		Gdip_DrawImage(G%A_Index%, pBitmap%A_Index%_down, 0, 0, buttons[A_Index]["w"], buttons[A_Index]["h"], 0, 0, buttons[A_Index]["w"], buttons[A_Index]["h"])
	}
	Return
}

MouseMove(wParam, lParam, msg, hwnd)
{
	Global
	local mhwnd
	MouseGetPos,,,,mhwnd,2
	Static _LastButtonData = true
	If(mhwnd != _LastButtonData)	;光标移动到新控件
	{
		Loop, % buttons["max"]
		{
			If(mhwnd = hButton%A_Index%)	;移入
			Gdip_DrawImage(G%A_Index%, pBitmap%A_Index%_over, 0, 0, buttons[A_Index]["w"], buttons[A_Index]["h"], 0, 0, buttons[A_Index]["w"], buttons[A_Index]["h"])
			If(_LastButtonData = hButton%A_Index%)	;移出
			Gdip_DrawImage(G%A_Index%, pBitmap%A_Index%_up, 0, 0, buttons[A_Index]["w"], buttons[A_Index]["h"], 0, 0, buttons[A_Index]["w"], buttons[A_Index]["h"])
		}
	}
	_LastButtonData := mhwnd
;~ 	ToolTip, % wParam "," lParam "," msg "," hwnd
;~ 	ToolTip, % mhwnd
	Return
}

addPicButton(label,Option,picUp,picOver,picDown)
{
	global
	local hwndget,w,h,hdc
	static buttonIndex=0
	buttonIndex++
	If(!isObject(buttons))
	buttons:=Object()
	If(!isObject(events))
	events:=Object()
;~ 	Gui, Add, Pic, % Option " hwndhButton" buttonIndex, % "PicButton" buttonIndex
	Gui, Add, Pic, % Option " hwndhButton" buttonIndex,
	Gui, Show, AutoSize
	pBitmap%buttonIndex%_up:=Gdip_CreateBitmapFromFile(picUp)
	pBitmap%buttonIndex%_over:=Gdip_CreateBitmapFromFile(picOver)
	pBitmap%buttonIndex%_down:=Gdip_CreateBitmapFromFile(picDown)
	hdc:=GetDC(hButton%buttonIndex%)
	G%buttonIndex% := Gdip_GraphicsFromHDC(hdc)
	hwndget:=hButton%buttonIndex%
	ControlGetPos, ,, w, h,,ahk_id %hwndget%
	buttons[buttonIndex,"w"]:=w
	buttons[buttonIndex,"h"]:=h
	buttons["max"]:=buttonIndex
	events[hwndget]:=label
	Gdip_DrawImage(G%buttonIndex%, pBitmap%buttonIndex%_up, 0, 0, w, h, 0, 0, w, h)
	buttonMax:=buttonIndex
	Return, buttonIndex
}
