

h2FontStyle:="s22 w600 c505050 q5"
textFontStyle:="s12 w400 cblack q5"
clientWidth:=450
header_gap:=" y+30 "
item_gap:=" y+10 "
Gui, setup:New, +ToolWindow -DPIScale +Ownermain hwndsetup_id
gui, font, s32 w700 cc07070, Microsoft JhengHei
gui, font, , Verdana
gui, font, , MV Boli
gui, add, Text, x10 y10,DoMiSo Setup
; gui, add, Text, x0 y+-50 +BackgroundTrans, ---------------------

gui, font, %textFontStyle%

gui, add, Text, x30 Section y+10, Log Level (日志级别)
log_ddl:=logLevel+1
gui, add, DropDownList, xs r4 wp vsetup_loglevel Choose%log_ddl% %item_gap%, 0|1|2|3

Gui, Add, CheckBox, xs y+50 vsetup_autoupdate Checked%autoUpdate%, AutoUpdate (自动更新)
gui, add, CheckBox, xs %item_gap% vsetup_globalmode Checked%global_mode%, Global Mode (全局模式)
gui, add, CheckBox, xs %item_gap% gsetup_tononadmin vsetup_nonadmin Checked%nonAdmin%, Non Admin Mode (非管理员模式)
gui, add, CheckBox, xs %item_gap% vsetup_startmusic Checked%startup_music%, Start up music (启动音乐)

btnWidth:=(clientWidth-30*2-10)//2
gui, add, Button, xs r2 w%btnwidth% gsetup_save, Save
gui, add, Button, x+10 hp wp gsetup_cancel, Cancel


setup_gui_show()
{
	global
	gui, setup:show, w%clientWidth%
}

setup_gui_action()
{
	global
	setup_save:
	gui, setup:submit
	IniWrite, %setup_nonadmin%, setting.ini, update, nonAdminMode
	IniWrite, %setup_startmusic%, setting.ini, update, startupMusic
	IniWrite, %setup_globalmode%, setting.ini, setup, globalMode
	IniWrite, %setup_loglevel%, setting.ini, update, log
	IniWrite, %setup_autoupdate%, setting.ini, update, autoupdate
	Reload
	Return
	setup_tononadmin:
	gui, setup:submit, NoHide
	if(setup_nonadmin==1) {
		MsgBox, 0x41040, NOTICE, you should close and relaunch this app to apply non admin mode`n`n需要关闭再重新打开软件才能应用非管理员模式
	}
	Return
	setup_cancel:
	Gui, setup:Hide
	Return
}
