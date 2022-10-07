
#SingleInstance, Force
SetWorkingDir, %A_ScriptDir%

#include meta.ahk

if FileExist(binaryFilename)
{
	FileDelete, %binaryFilename%
}

if FileExist(versionFilename)
{
	FileDelete, %versionFilename%
}

if InStr(FileExist("dist"), "D")
{
	FileRemoveDir, dist, 1
	If (ErrorLevel)
	{
		MsgBox, % "removing dist`nERROR CODE=" ErrorLevel
		ExitApp
	}
}

FileCreateDir, dist

RunWait, ahk_compiler/ahk2exe.exe /in updater.ahk /out updater.exe /compress 1 /base "ahk_compiler/AutoHotkeyU64.exe"
If (ErrorLevel)
{
	MsgBox, % "updater.ahk`nERROR CODE=" ErrorLevel
	ExitApp
}
RunWait, ahk_compiler/ahk2exe.exe /in %ahkFilename% /out %binaryFilename% /compress 1 /base "ahk_compiler/AutoHotkeyU64.exe"
If (ErrorLevel)
{
	MsgBox, % ahkFilename "`nERROR CODE=" ErrorLevel
	ExitApp
}
RunWait, ahk_compiler/AutoHotkeyU64.exe .\%ahkFilename% --out=version
If (ErrorLevel)
{
	MsgBox, % "get version`nERROR CODE=" ErrorLevel
	ExitApp
}
RunWait, powershell -command "Compress-Archive -Path .\%binaryFilename%`, .\free_sheets -DestinationPath %downloadFilename%",, Hide
If (ErrorLevel)
{
	MsgBox, % "compress`nERROR CODE=" ErrorLevel
	ExitApp
}
FileDelete, %binaryFilename%
FileDelete, updater.exe
FileMove, %downloadFilename%, dist\%downloadFilename%, 1
FileMove, %versionFilename%, dist\%versionFilename%, 1
MsgBox, Build Finished
