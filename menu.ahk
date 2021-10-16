
menu()
{
	global
	Menu, Tray, NoStandard
	Menu, Tray, Add, % "v" version,donothing
	Menu, Tray, Add
	Menu, Tray, Add, Github 页面, pages
	Menu, Tray, Add, Donate 捐助, donate
	Menu, Tray, Add, History 更新历史, changesfile
	Menu, Tray, Add, Exit, Exit
	Menu, Tray, Click, 1
}

donate:
Run, https://ko-fi.com/xianii
Return
pages:
Run, https://github.com/Nigh/DoMiSo-genshin
Return
donothing:
Return
changesfile:
Run, notepad.exe %A_Temp%\domiso\changes.md
Return
