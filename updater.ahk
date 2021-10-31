#SingleInstance, ignore
SetWorkingDir, %A_ScriptDir%

#include meta.ahk

RunWait, powershell -command "Expand-Archive -Force %downloadFilename% .",, Hide
FileDelete, % downloadFilename
Run, %binaryFilename%

ExitApp
