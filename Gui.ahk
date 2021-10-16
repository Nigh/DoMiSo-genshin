;~ guiDebug:=1
#Include lib/Gdip.ahk
pToken := Gdip_Startup()
if(clean_start){
	sample_sheet := ""
} else {
	sample_sheet =
(
v0.99.0 Update log:

- 添加了日志系统
- 添加了自动更新功能
- 更改了按键名称
- 添加了音符统计，显示在状态栏
- 添加了开场音乐开关，可以关闭开场播放的音乐
- 添加了清净开场开关，打开软件可以自动清空编辑栏
- 添加了非管理员模式，方便编辑和试听
- 修复了试听按键的状态在播放完成后不会自动恢复的问题
- 

Video: 


相关视频
首发视频：https://www.bilibili.com/video/BV1564y1Q7Uq/
0.4版本更新视频：https://www.bilibili.com/video/BV1tA411g7XM/
编谱教程01：https://www.bilibili.com/video/BV1pX4y1G76r/

===============

1=C
bpm=150
+3/// +5/// +7// ++1/ ++3/ ++5/ +++1
rollback=9999
-1/ -3 -5/ 1/

)
}

ui:={}
ui_gap:=23
ui.size:={w:500,h:782}
ui.title:={}
ui.title.pos:={x:ui_gap,y:ui_gap}
ui.title.size:={w:ui.size.w-2*ui.title.pos.x,h:48}
ui.ver:={}
ui.ver.pos:={x:ui.size.w-ui.size.w//3-ui_gap,y:1.8*ui_gap}
ui.ver.size:={w:ui.size.w//3,h:35}

ui.statuBar:={}
ui.statuBar.pos:={x:4,y:ui.size.h-22-4}
ui.statuBar.size:={w:ui.size.w-8,h:22}

button_count:=3
ui.button_h:=56
ui.button1:={}
ui.button1.pos:={x:ui.title.pos.x,y:ui.size.h-2*(ui.button_h+ui_gap)-ui.statuBar.size.h}
ui.button1.size:={w:(ui.size.w-(button_count+1)*ui_gap)//button_count,h:ui.button_h}
ui.button2:={}
ui.button2.pos:={x:ui_gap+ui.button1.size.w+ui.button1.pos.x,y:ui.button1.pos.y}
ui.button2.size:={w:ui.button1.size.w,h:ui.button1.size.h}
ui.button3:={}
ui.button3.pos:={x:ui_gap+ui.button2.size.w+ui.button2.pos.x,y:ui.button2.pos.y}
ui.button3.size:={w:ui.button1.size.w,h:ui.button1.size.h}

ui.buttonFile:={}
ui.buttonFile.pos:={x:ui.button1.pos.x,y:ui.button1.pos.y+ui.button_h+ui_gap}
ui.buttonFile.size:={w:ui.button1.size.w,h:ui.button1.size.h}
ui.buttonPub:={}
ui.buttonPub.pos:={x:ui.buttonFile.pos.x+ui.button1.size.w+ui_gap,y:ui.buttonFile.pos.y}
ui.buttonPub.size:={w:ui.button1.size.w*2+ui_gap,h:ui.button1.size.h}


ui.hatch:=50
ui.bgcolor:=0xffdcdcdc
ui.fgcolor:=0xffd2d4d3
Gui, -Caption -DPIScale -AlwaysOnTop -Owner +OwnDialogs hwndgui_id
Gui, Color, % ui.fgcolor, % ui.bgcolor
Gui, Add, pic, x0 y0 w1 h1 0xE hwndhBg, 
Gui, Add, pic, % "x" ui.title.pos.x " y" ui.title.pos.y " w" ui.title.size.w " h" ui.title.size.h " gtitleMove 0xE hwndhTitle", 
Gui, Add, pic, % "x" ui.ver.pos.x " y" ui.ver.pos.y " w" ui.ver.size.w " h" ui.ver.size.h " 0xE hwndhVer", 
edit_y:=3.5*ui_gap
edit_height:=ui.size.h-edit_y-2*ui.button1.size.h-3*ui_gap-ui.statuBar.size.h
Gui, Add, Edit, x30 y%edit_y% w440 h%edit_height% vediter hwndhEdit1, % sample_sheet

Gui, Add, pic, % "x" ui.button1.pos.x " y" ui.button1.pos.y-20 " w" ui.button1.size.w " h20 0xE hwndhHotkey", 

Gui, Add, pic, % "x" ui.button1.pos.x " y" ui.button1.pos.y " w" ui.button1.size.w " h" ui.button1.size.h " 0xE hwndhBtn1 gfunc_btn_play", 
Gui, Add, pic, % "x" ui.button2.pos.x " y" ui.button2.pos.y " w" ui.button2.size.w " h" ui.button2.size.h " 0xE hwndhBtn2 gfunc_btn_listen", 
Gui, Add, pic, % "x" ui.button3.pos.x " y" ui.button3.pos.y " w" ui.button3.size.w " h" ui.button3.size.h " 0xE hwndhBtn3 gfunc_btn_exit", 

Gui, Add, pic, % "x" ui.buttonFile.pos.x " y" ui.buttonFile.pos.y " w" ui.buttonFile.size.w " h" ui.buttonFile.size.h " 0xE hwndhBtnFile gfunc_btn_file", 
Gui, Add, pic, % "x" ui.buttonPub.pos.x " y" ui.buttonPub.pos.y " w" ui.buttonPub.size.w " h" ui.buttonPub.size.h " 0xE hwndhBtnPub gfunc_btn_publish", 

Gui, Add, pic, % "x" ui.statuBar.pos.x " y" ui.statuBar.pos.y " w" ui.statuBar.size.w " h" ui.statuBar.size.h " 0xE hwndhStatuBar", 


hBitmap:={}
if debug
{
	hBitmap.title:=hBitmapBy2ColorAndText(ui.title.size.w,ui.title.size.h,ui.fgcolor,"DEBUG","bold cFFCC9999 S48 Left")
}
Else
{
	hBitmap.title:=hBitmapBy2ColorAndText(ui.title.size.w,ui.title.size.h,ui.fgcolor,"DoMiSo","bold cFFCC9999 S48 Left")
}
hBitmap.genshin:=hBitmapBy2ColorAndText(ui.ver.size.w,ui.ver.size.h,ui.fgcolor,"Genshin v" version "`n@github.com/Nigh","cFF666666 S14 Right")

hBitmap.hotkey:=hBitmapBy2ColorAndText(ui.button1.size.w,20,ui.fgcolor,"F8:Stop F9:Start","bold cFFCC9999 S14 Left")

hBitmap.button1:=hBitmapByBorderHatchAndText(ui.button1.size.w,ui.button1.size.h, 0xffad395c,2,ui.fgcolor,ui.bgcolor,ui.hatch,"Play")
hBitmap.button1Hover:=hBitmapByBorderHatchAndText(ui.button1.size.w,ui.button1.size.h, 0xffad395c,8,0xffad395c,ui.bgcolor,38,"Play")
hBitmap.button1Playing:=hBitmapByBorderHatchAndText(ui.button1.size.w,ui.button1.size.h, 0xff4b4b4b,4,0xffbbbbbb,ui.bgcolor,ui.hatch,"Stop")
hBitmap.button1PlayingHover:=hBitmapByBorderHatchAndText(ui.button1.size.w,ui.button1.size.h, 0xff4b4b4b,8,0xff4b4b4b,ui.bgcolor,ui.hatch,"Stop")

hBitmap.button2:=hBitmapByBorderHatchAndText(ui.button2.size.w,ui.button2.size.h, 0xffbbbb2b,2,ui.fgcolor,ui.bgcolor,ui.hatch,"Listen")
hBitmap.button2Hover:=hBitmapByBorderHatchAndText(ui.button2.size.w,ui.button2.size.h, 0xffada95c,8,0xffada95c,ui.bgcolor,21,"Listen")
hBitmap.button2Playing:=hBitmapByBorderHatchAndText(ui.button2.size.w,ui.button2.size.h, 0xff4b4b4b,4,0xffbbbbbb,ui.fgcolor,ui.hatch,"Stop")
hBitmap.button2PlayingHover:=hBitmapByBorderHatchAndText(ui.button2.size.w,ui.button2.size.h, 0xff4b4b4b,8,0xff9b9b9b,ui.bgcolor,ui.hatch,"Stop")

hBitmap.button3:=hBitmapByBorderHatchAndText(ui.button3.size.w,ui.button3.size.h, 0xff4b4b4b,2,ui.fgcolor,ui.bgcolor,ui.hatch,"Exit")
hBitmap.button3Hover:=hBitmapByBorderHatchAndText(ui.button3.size.w,ui.button3.size.h, 0xffad395c,8,0xffad395c,ui.bgcolor,23,"Exit")

hBitmap.buttonFile:=hBitmapByBorderHatchAndText(ui.buttonFile.size.w,ui.buttonFile.size.h, 0xff1b1b4b,2,ui.fgcolor,ui.bgcolor,ui.hatch,"File")
hBitmap.buttonFileHover:=hBitmapByBorderHatchAndText(ui.buttonFile.size.w,ui.buttonFile.size.h, 0xff395cad,8,0xff395cad,ui.bgcolor,7,"File")

hBitmap.buttonPub:=hBitmapByBorderHatchAndText(ui.buttonPub.size.w,ui.buttonPub.size.h, 0xff1b4b4b,2,ui.fgcolor,ui.bgcolor,ui.hatch,"Encrypt")
hBitmap.buttonPubHover:=hBitmapByBorderHatchAndText(ui.buttonPub.size.w,ui.buttonPub.size.h, 0xff39ad5c,8,0xff39ad5c,ui.bgcolor,40,"Encrypt")

hBitmap.bg:=hBitmapByBorderHatchAndText(ui.size.w,ui.size.h, 0xff646464,4,ui.fgcolor,ui.bgcolor,ui.hatch)

SetImage(hBg,hBitmap.bg)
SetImage(hTitle,hBitmap.title)
SetImage(hVer,hBitmap.genshin)
; SetImage(gui_by.Hwnd,hBitmap.by)
SetImage(hHotkey,hBitmap.hotkey)
SetImage(hBtn1,hBitmap.button1)
SetImage(hBtn2,hBitmap.button2)
SetImage(hBtn3,hBitmap.button3)
SetImage(hBtnFile,hBitmap.buttonFile)
SetImage(hBtnPub,hBitmap.buttonPub)
statubar_txt("v" version)
Gui, Show, % "w" ui.size.w " h" ui.size.h

OnMessage(0x200, "MouseMove")
OnMessage(0x201, "MouseDown")
OnMessage(0x203, "MouseDown")
OnMessage(0x202, "MouseUp")

MouseUp(wParam, lParam, msg, hwnd)
{
	global
	local mhwnd
	MouseGetPos,,,,mhwnd,2
}

MouseDown(wParam, lParam, msg, hwnd)
{
	global
	local mhwnd
	MouseGetPos,,,,mhwnd,2
}

statubar_txt(txt)
{
	global hStatuBar, ui
	_hBitmap := hBitmapByColorAndText(ui.statuBar.size.w,ui.statuBar.size.h,0xff646464,txt,"bold cffd2d4d3 S18 Right")
	SetImage(hStatuBar,_hBitmap)
	DeleteObject(_hBitmap)
}

btn1update()
{
	global
	btn_release(hBtn1)
}
btn2update()
{
	global
	btn_release(hBtn2)
}

btn_release(hwnd)
{
	global
	if(hwnd==hBtn1)
	{
		if(isBtn1Playing)
		{
			SetImage(hBtn1,hBitmap.button1Playing)
		}
		Else
		{
			SetImage(hBtn1,hBitmap.button1)
		}
	}
	if(hwnd==hBtn2)
	{
		if(isBtn2Playing)
		{
			SetImage(hBtn2,hBitmap.button2Playing)
		}
		Else
		{
			SetImage(hBtn2,hBitmap.button2)
		}
	}
	if(hwnd==hBtn3)
	{
		SetImage(hBtn3,hBitmap.button3)
	}
	if(hwnd==hBtnPub)
	{
		SetImage(hBtnPub,hBitmap.buttonPub)
	}
	if(hwnd==hBtnFile)
	{
		SetImage(hBtnFile,hBitmap.buttonFile)
	}
}

MouseMove(wParam, lParam, msg, hwnd)
{
	Global
	local mhwnd
	If(WinExist("A")!=gui_id)
	Return
	MouseGetPos,,,,mhwnd,2
	Static _LastButtonData = true
	If(mhwnd != _LastButtonData)	;光标移动到新控件
	{
		btn_release(_LastButtonData)
		if(mhwnd==hBtn1)
		{
			if(isBtn1Playing)
			{
				SetImage(hBtn1,hBitmap.button1PlayingHover)
			}
			Else
			{
				SetImage(hBtn1,hBitmap.button1Hover)
			}
		}
		if(mhwnd==hBtn2)
		{
			if(isBtn2Playing)
			{
				SetImage(hBtn2,hBitmap.button2PlayingHover)
			}
			Else
			{
				SetImage(hBtn2,hBitmap.button2Hover)
			}
		}
		if(mhwnd==hBtn3)
		{
			SetImage(hBtn3,hBitmap.button3Hover)
		}
		if(mhwnd==hBtnPub)
		{
			SetImage(hBtnPub,hBitmap.buttonPubHover)
		}
		if(mhwnd==hBtnFile)
		{
			SetImage(hBtnFile,hBitmap.buttonFileHover)
		}
	}
	_LastButtonData := mhwnd
	Return
}


hBitmapHatch(w,h,bgcolor:=0xffff0000,fgcolor:=0xff00ff00,hatch:=0)
{
	pBitmap := Gdip_CreateBitmap(w, h)
	G := Gdip_GraphicsFromImage(pBitmap)
	Gdip_SetSmoothingMode(G, 4)
	pBrush := Gdip_BrushCreateHatch(fgcolor,bgcolor,hatch)
	Gdip_FillRectangle(G, pBrush, -1, -1, w+1, h+1)
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	Gdip_DeleteBrush(pBrush)
	Gdip_DeleteGraphics(G)
	Gdip_DisposeImage(pBitmap)
	Return hBitmap
}
hBitmapByBorderHatchAndText(w,h,bdcolor:=0xffffffff,bdwidth:=1,fgcolor:=0xff00ff00,bgcolor:=0xff00ff00,hatch:=1,text:="",option:="")
{
	global ui
	pBitmap := Gdip_CreateBitmap(w, h)
	G := Gdip_GraphicsFromImage(pBitmap)
	Gdip_SetSmoothingMode(G, 4)
	pBrush := Gdip_BrushCreateHatch(fgcolor,bgcolor,hatch)
	Gdip_FillRectangle(G, pBrush, -1, -1, w+1, h+1)
	if(text!=""){
		if(option="")
			Gdip_TextToGraphics(G, text,"cFF444444 S20 Center vCenter","Consolas",w,h)
		Else
			Gdip_TextToGraphics(G, text,option,"Consolas",w,h)
	}
	Gdip_DeleteBrush(pBrush)
	if(bdwidth>0){
		pBrush := Gdip_BrushCreateSolid(bdcolor)
		Gdip_FillRectangle(G, pBrush, -1, -1, w, bdwidth+1)
		Gdip_FillRectangle(G, pBrush, 1, h-bdwidth-1, w, h)
		Gdip_FillRectangle(G, pBrush, -1, -1, bdwidth+1, h)
		Gdip_FillRectangle(G, pBrush, w-bdwidth-1, 1, w-1, h)
	}
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	Gdip_DeleteBrush(pBrush)
	Gdip_DeleteGraphics(G)
	Gdip_DisposeImage(pBitmap)
	Return hBitmap
}
hBitmapBy2ColorAndText(w,h,fgcolor:=0xff00ff00,text:="",option:="")
{
	global ui
	Return hBitmapByBorderHatchAndText(w,h,,0,fgcolor,ui.bgcolor,ui.hatch,text,option)
}
hBitmapByColorAndText(w,h,bgcolor:=0xffff0000,text:="",option:="")
{
	pBitmap := Gdip_CreateBitmap(w, h)
	G := Gdip_GraphicsFromImage(pBitmap)
	Gdip_SetSmoothingMode(G, 4)
	pBrush := Gdip_BrushCreateSolid(bgcolor)
	Gdip_FillRectangle(G, pBrush, -1, -1, w+1, h+1)
	if(text!=""){
		if(option="")
			Gdip_TextToGraphics(G, text,"cFFf1f1f1 S20 Center vCenter","Consolas",w,h)
		Else
			Gdip_TextToGraphics(G, text,option,"Consolas",w,h)
	}
	hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmap)
	Gdip_DeleteBrush(pBrush)
	Gdip_DeleteGraphics(G)
	Gdip_DisposeImage(pBitmap)
	Return hBitmap
}
