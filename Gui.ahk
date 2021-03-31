;~ guiDebug:=1
pToken := Gdip_Startup()
sample_sheet =
(
QWEQQWEQ(ED)(RF)(TG)(ED)(RF)(TG)
TYTR(ED)(QA)TYTR(ED)(QA)
WG(QG)WG(QAG)
)
ui:={}
ui_gap:=23
ui.size:={w:500,h:750}
ui.title:={}
ui.title.pos:={x:ui_gap,y:ui_gap}
ui.title.size:={w:ui.size.w-2*ui.title.pos.x,h:48}
ui.ver:={}
ui.ver.pos:={x:ui.size.w//2-ui_gap,y:1.8*ui_gap}
ui.ver.size:={w:ui.size.w//2,h:35}
button_count:=2
ui.button_h:=56
ui.button1:={}
ui.button1.pos:={x:ui.title.pos.x,y:ui.size.h-ui.button_h-ui_gap}
ui.button1.size:={w:(ui.size.w-(button_count+1)*ui_gap)//button_count,h:ui.button_h}
ui.button2:={}
ui.button2.pos:={x:ui_gap+ui.button1.size.w+ui.button1.pos.x,y:ui.button1.pos.y}
ui.button2.size:={w:ui.button1.size.w,h:ui.button1.size.h}
ui.hatch:=50
ui.bgcolor:=0xffdcdcdc
ui.fgcolor:=0xffd2d4d3
Gui, -Caption -DPIScale -AlwaysOnTop -Owner hwndgui_id
Gui, Color, % ui.fgcolor, % ui.bgcolor
Gui, Add, pic, x0 y0 w1 h1 0xE hwndhBg, 
Gui, Add, pic, % "x" ui.title.pos.x " y" ui.title.pos.y " w" ui.title.size.w " h" ui.title.size.h " gtitleMove 0xE hwndhTitle", 
Gui, Add, pic, % "x" ui.ver.pos.x " y" ui.ver.pos.y " w" ui.ver.size.w " h" ui.ver.size.h " 0xE hwndhVer", 
edit_y:=3.5*ui_gap
checkbox_height:=15
edit_height:=ui.size.h-edit_y-ui.button1.size.h-2*ui_gap
checkbox_y:=edit_y+edit_height+0
Gui, Add, Edit, x30 y%edit_y% w440 h%edit_height% vediter hwndhEdit1, % sample_sheet
Gui, add, Checkbox, x30 y%checkbox_y% h%checkbox_height% vhardcore, 硬核模式
Gui, Add, pic, % "x" ui.button1.pos.x " y" ui.button1.pos.y " w" ui.button1.size.w " h" ui.button1.size.h " 0xE hwndhBtn1 gfunc_btn_play", 
Gui, Add, pic, % "x" ui.button2.pos.x " y" ui.button2.pos.y " w" ui.button2.size.w " h" ui.button2.size.h " 0xE hwndhBtn3 gfunc_btn_exit", 
; Gui, Add, pic, % "x" ui.button4.pos.x " y" ui.button4.pos.y " w" ui.button4.size.w " h" ui.button4.size.h " 0xE hwndhBtn4", 
Gui, Show, % "w" ui.size.w " h" ui.size.h

hBitmap:={}
hBitmap.title:=hBitmapBy2ColorAndText(ui.title.size.w,ui.title.size.h,ui.fgcolor,"DoMiSo","bold cFF7799CC S48 Left")
hBitmap.genshin:=hBitmapBy2ColorAndText(ui.ver.size.w,ui.ver.size.h,ui.fgcolor,"Genshin.0.3M`n@github.com/Nigh","cFF666666 S14 Right")

hBitmap.button1:=hBitmapByBorderHatchAndText(ui.button1.size.w,ui.button1.size.h, 0xffad395c,2,ui.fgcolor,ui.bgcolor,ui.hatch,"Play")
hBitmap.button1Hover:=hBitmapByBorderHatchAndText(ui.button1.size.w,ui.button1.size.h, 0xffad395c,8,0xffad395c,ui.bgcolor,38,"Play")
hBitmap.button1Playing:=hBitmapByBorderHatchAndText(ui.button1.size.w,ui.button1.size.h, 0xff4b4b4b,4,0xffbbbbbb,ui.bgcolor,ui.hatch,"Stop")
hBitmap.button1PlayingHover:=hBitmapByBorderHatchAndText(ui.button1.size.w,ui.button1.size.h, 0xff4b4b4b,8,0xff4b4b4b,ui.bgcolor,ui.hatch,"Stop")

hBitmap.button2:=hBitmapByBorderHatchAndText(ui.button2.size.w,ui.button2.size.h, 0xff4b4b4b,2,ui.fgcolor,ui.bgcolor,23,"Exit")
hBitmap.button2Hover:=hBitmapByBorderHatchAndText(ui.button2.size.w,ui.button2.size.h, 0xffad395c,8,0xffad395c,ui.bgcolor,23,"Exit")

hBitmap.bg:=hBitmapByBorderHatchAndText(ui.size.w,ui.size.h, 0xff646464,4,ui.fgcolor,ui.bgcolor,ui.hatch)

SetImage(hBg,hBitmap.bg)
SetImage(hTitle,hBitmap.title)
SetImage(hVer,hBitmap.genshin)
; SetImage(gui_by.Hwnd,hBitmap.by)
SetImage(hBtn1,hBitmap.button1)
; SetImage(hBtn2,hBitmap.button2)
SetImage(hBtn3,hBitmap.button2)
; SetImage(hBtn4,hBitmap.button4)

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

btn1update()
{
	global
	btn_release(hBtn1)
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
	if(hwnd==hBtn3)
	{
		SetImage(hBtn3,hBitmap.button2)
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
		if(mhwnd==hBtn3)
		{
			SetImage(hBtn3,hBitmap.button2Hover)
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
