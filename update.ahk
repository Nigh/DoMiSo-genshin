

outputVersion(){
	global
	version:="0.99.0"
	if A_Args.Length() > 0
	{
		for n, param in A_Args
		{
			RegExMatch(param, "--out=(\w+)", outName)
			if(outName1=="version") {
				f := FileOpen("version.txt","w")
				f.Write(version)
				f.Close()
				ExitApp
			}
		}
	}
}


downloadUrlBase:="https://download.fastgit.org/Nigh/DoMiSo-genshin/releases/latest/download/"
versionFilename:="version.txt"
binaryFilename:="DomisoGenshin.zip"

IniRead, logLevel, setting.ini, update, log, 0
IniRead, lastUpdate, setting.ini, update, last, 0
IniRead, autoUpdate, setting.ini, update, autoupdate, 1
IniRead, version_str, setting.ini, update, ver, "0"
log_write("Start at " A_YYYY "-" A_MM "-" A_DD, 0)
today:=A_MM . A_DD
if(autoUpdate) {
	if(lastUpdate!=today) {
		log_write("Getting Update",0)
		MsgBox,,Update,Getting Update`n获取最新版本,2
		get_latest_version()
	} else {
		ttm("Domiso automata Start`nv" version "`n原神弹琴人偶启动")
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
	; https://download.fastgit.org/Nigh/Genshin-fishing/releases/latest/download/version.txt
	; https://github.com/Nigh/Genshin-fishing/releases/latest/download/version.txt
	req.open("GET", downloadUrlBase versionFilename, true)
	req.onreadystatechange := Func("updateReady")
	req.send()
}

; with MSXML2.ServerXMLHTTP method, there would be multiple callback called
updateReqDone:=0
updateReady(){
	global req, version, updateReqDone
	log_write("update req.readyState=" req.readyState, 1)
    if (req.readyState != 4){  ; Not done yet.
        return
	}
	if(updateReqDone){
		log_write("state already changed", 1)
		Return
	}
	updateReqDone := 1
	log_write("update req.status=" req.status, 1)
    if (req.status == 200){ ; OK.
        ; MsgBox % "Latest version: " req.responseText
		RegExMatch(version, "(\d+)\.(\d+)\.(\d+)", verNow)
		RegExMatch(req.responseText, "(\d+)\.(\d+)\.(\d+)", verNew)
		if(verNow1*10000+verNow2*100+verNow3<verNew1*10000+verNew2*100+verNew3) {
			MsgBox, 0x24, Download, % "Found new version " req.responseText ", download?`n`n发现新版本 " req.responseText " 是否下载?"
			IfMsgBox Yes
			{
				UrlDownloadToFile, % downloadUrlBase binaryFilename, % "./" binaryFilename
				if(ErrorLevel) {
					MsgBox, 16,, % "Download failed`n下载失败"
				} else {
					MsgBox, ,, % "File saved as " binaryFilename "`n更新下载完成 " binaryFilename "`n`nProgram will exit now`n软件即将退出", 2
					IniWrite, % A_MM A_DD, setting.ini, update, last
					ExitApp
				}
			}
		} else {
			MsgBox, ,, % "Current version: v" version "`n`nIt is the latest version`n`n软件已是最新版本", 2
			IniWrite, % A_MM A_DD, setting.ini, update, last
		}
	} else {
        MsgBox, 16,, % "Update failed`n`n更新失败`n`nStatus=" req.status
	}
}
