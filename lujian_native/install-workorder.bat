@echo off
adb install -r "%~dp0releases\workorder_app\lujian-workorder-debug.apk"
adb shell am start -n com.lujian.lujian_workorder/.MainActivity
