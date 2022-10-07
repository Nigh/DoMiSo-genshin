
FileEncoding, UTF-8

; 是否内测版本
betaBuild:=1

name_en:="Domiso Automata"
name_zh:="原神自动弹琴人偶"
version:="0.99.7b"
versionFilename:="version.txt"
ahkFilename:="DoMiSo.ahk"
binaryFilename:="Domiso-Genshin.exe"
downloadFilename:="DomisoGenshin.zip"
downloadUrl:="/Nigh/DoMiSo-genshin/releases/latest/download/"

if(betaBuild=1) {
	version:=version . " BETA"
}
