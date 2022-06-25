# Changes

Domiso原神特别版

Domiso for Genshin

## v0.99.7

- 扩展了和弦语法
- 新增连音语法
- 新增琶音语法

## v0.99.6

- 修改音符时值为浮点数计算，解决了拍子时值量化误差的积累问题
- Note time values are now calculated as floating point numbers, solving the problem of accumulating quantization errors in beat time values
- 增加了拍子统计，自动统计拍子数，方便对齐节拍
- Beat count statistics have been added, automatically counting the number of beats and making it easier for you to align the beats
- 增加了一个设置面板，右键单击任务栏图标进入设置
- A settings panel has been added, right-click on the taskbar icon to enter settings
- 增加对于没有midi输出的系统的支持，无midi输出的系统可以演奏，仅无法试听
- Add support for systems without midi output, systems without midi output will only not be able to "listen"

## v0.99.5

- 取消了模拟按键的延迟，现在和弦的每个音符将会同时响应
- The key simulation delay has been removed and each note of the chord will now respond simultaneously

## v0.99.4

- 现在更新源将会自动选择
- The update source will now be automatically selected

## v0.99.3

- 修复了试听音色保存的问题，之前在音色为第一种时退出会发生问题
- Fixed the problem of saving instruments settings, which previously occurred when the instruments was the first one to exit
- 现在导入谱面的同时就会自动解析音符了，之前为试听或演奏开始才解析
- The notes are now automatically resolved when importing a sheet, instead of only at the beginning of listening or playing.
- 增加了免费示例谱面
- Added free sample sheets

## v0.99.2

- 添加了选择试听音色的功能
- Now you can choose the instrument for listening

## v0.99.0

- 添加了原神国际版支持
- Added support for Genshin Impact (International Edition)
- 添加了日志系统
- Added logging system
- 添加了自动更新功能
- Added automatic update function
- 更改了按键名称
- Changed button names
- 添加了音符统计，显示在状态栏
- Added note statistics to the status bar
- 添加了开场音乐开关，可以关闭开场播放的音乐
- Added opening music switch, you can turn off the music played at the beginning now
- 添加了清净开场开关，打开软件可以自动清空编辑栏
- Added a clean opening switch, it could clear the editor when you open the software now
- 添加了非管理员模式，方便编辑和试听
- Added non-admin mode, convenient for editing and auditioning
- 修复了试听按键的状态在播放完成后不会自动恢复的问题
- Fix the problem that the status of the listen button will not be restored automatically after the playback is finished

## v0.4

- 添加谱面加密发布功能
- Add the function of encrypting the numbered musical notation
- 添加自动请求管理员权限功能
- Add the function of requesting administrator permission automatically

## v0.32A

- 修复括号和弦的时值会错误的受到上一个括号和弦时值的影响的问题
- Fix the problem that the time of bracketed chords is wrongly affected by the time of the previous bracketed chord

## v0.31A

- 修复快捷键功能异常的问题
- Fix the problem of abnormal shortcut key function

## v0.3A

- 添加F9为开始快捷键
- Added F9 as the start shortcut key
- 更改标题颜色，以便与手搓版区分
- Change the title color to distinguish it from the manual version

## v0.2A

- 重写了UI
- Rewrote the UI
- 原神特别版初版，附带自动演奏功能
- first version of Genshin Special Edition with auto-play function

## v0.1a Alpha 

- 添加一个停止按钮
- Add a stop button
- 添加点击托盘图标激活主窗体功能
- Add a tray icon to activate the main form
- 添加一个窗口置顶按钮
- Added a window top button
- 略微更改了标题栏的交互
- Slightly changed the interaction of the title bar

## v0.1 Alpha

- 第一个demo发布
- First demo released
