
log_init()
{
	global
	local buffer, size
	if(FileExist("domiso.log")) {
		FileGetSize, size, domiso.log, K
		if(size > 512) {
			FileDelete, "domiso.log"
		} else if(size > 128) {
			FileRead, buffer, domiso.log
			pLogfile:=FileOpen("domiso.log", "w")
			pLogfile.WriteLine("Deleted old logs to keep log files smaller than 128kb`r`n")
			buffer := SubStr(buffer, 1, StrLen(buffer)//2)
			pLogfile.Write(buffer)
			pLogfile.Close()
		}
	}
	pLogfile:=FileOpen("domiso.log", "a")
	Return
}

log_write(txt,level=0)
{
	global logLevel, pLogfile
	if(logLevel >= level) {
		pLogfile.WriteLine(A_Hour ":" A_Min ":" A_Sec "." A_MSec "[L" level "]:" txt)
	}
}

log_flush()
{
	global
	pLogfile.Close()
}

ttm(txt, delay=1500)
{
	ToolTip, % txt
	SetTimer, kttm, % -delay
	Return
	kttm:
	ToolTip,
	Return
}

tt(txt, delay=2000)
{
	ToolTip, % txt, 1, 1
	SetTimer, ktt, % -delay
	Return
	ktt:
	ToolTip,
	Return
}
