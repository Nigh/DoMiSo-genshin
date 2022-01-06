

#include meta.ahk

IfExist, updater.exe
{
	FileDelete, updater.exe
}
IniRead, logLevel, setting.ini, update, log, 0
IniRead, lastUpdate, setting.ini, update, last, 0
IniRead, autoUpdate, setting.ini, update, autoupdate, 1
IniRead, updateMirror, setting.ini, update, mirror, fastgit
IniWrite, % updateMirror, setting.ini, update, mirror
IniRead, version_str, setting.ini, update, ver, 0
IniRead, inst, setting.ini, update, inst, 11
log_write("Start at " A_YYYY "-" A_MM "-" A_DD, 0)
today:=A_MM . A_DD
if(autoUpdate) {
	if(lastUpdate!=today) {
		log_write("Getting Update",0)
		; MsgBox,,Update,Getting Update`n获取最新版本,2
		get_latest_version()
	} else {
		ttm(name_en " Start`nv" version "`n" name_zh "启动")
	}
} else {
	log_write("Update Skiped",0)
	if(lastUpdate!=today) {
		MsgBox,,Update,Update Skiped`n跳过升级`n`nCurrent version`n当前版本`nv%version%,2
		IniWrite, % A_MM A_DD, setting.ini, update, last
	}
}

get_latest_version(){
	global
	req := ComObjCreate("MSXML2.ServerXMLHTTP")
	if(updateMirror=="fastgit") {
		updateSite:="https://download.fastgit.org"
	} else if(updateMirror=="cnpmjs") {
		updateSite:="https://github.com.cnpmjs.org"
	} else {
		updateSite:="https://github.com"
	}
	req.open("GET", updateSite downloadUrl versionFilename, true)
	req.onreadystatechange := Func("updateReady")
	req.send()
}

; with MSXML2.ServerXMLHTTP method, there would be multiple callback called
updateReqDone:=0
updateReady(){
	global req, version, updateReqDone, updateSite, downloadUrl, downloadFilename
	log_write("update req.readyState=" req.readyState, 1)
    if (req.readyState != 4){  ; Not done yet.
        return
	}
	if(updateReqDone){
		; log_write("state already changed", 1)
		Return
	}
	updateReqDone := 1
	log_write("update req.status=" req.status, 1)
    if (req.status == 200){ ; OK.
        ; MsgBox % "Latest version: " req.responseText
		RegExMatch(version, "(\d+)\.(\d+)\.(\d+)", verNow)
		RegExMatch(req.responseText, "(\d+)\.(\d+)\.(\d+)", verNew)
		if((verNew1>verNow1)
		|| (verNew1==verNow1 && ((verNew2>verNow2)
			|| (verNew2==verNow2 && verNew3>verNow3)))){
			MsgBox, 0x24, Download, % "Found new version " req.responseText ", download?`n`n发现新版本 " req.responseText " 是否下载?"
			IfMsgBox Yes
			{
				try {
					UrlDownloadToFile, % updateSite downloadUrl downloadFilename, % "./" downloadFilename
					MsgBox, ,, % "Download finished`n更新下载完成`n`nProgram will restart now`n软件即将重启", 3
					IniWrite, % A_MM A_DD, setting.ini, update, last
					FileInstall, updater.exe, updater.exe, 1
					Run, updater.exe
					ExitApp
				} catch e {
					MsgBox, 16,, % "Upgrade failed`nAn exception was thrown!`nSpecifically: " e
				}
			}
		} else {
			; MsgBox, ,, % "Current version: v" version "`n`nIt is the latest version`n`n软件已是最新版本", 2
			IniWrite, % A_MM A_DD, setting.ini, update, last
		}
	} else {
        MsgBox, 16,, % "Update failed`n`n更新失败`n`nStatus=" req.status
	}
}
