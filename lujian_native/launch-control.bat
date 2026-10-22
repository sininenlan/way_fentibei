@echo off
set "LOCAL_EXE=%~dp0releases\control_console\lujian_control_console.exe"
if exist "%LOCAL_EXE%" (
    start "" "%LOCAL_EXE%"
    exit /b 0
)

set "INSTALLED_EXE=D:\LujianNativeApps\control_console\lujian_control_console.exe"
if exist "%INSTALLED_EXE%" (
    start "" "%INSTALLED_EXE%"
    exit /b 0
)

echo Control console was not found.
echo Run scripts\build-windows.ps1 first.
exit /b 1
