$ErrorActionPreference = "Stop"

$source = Resolve-Path (Join-Path $PSScriptRoot "..")
$buildRoot = "D:\lujian_native_build"
$destination = Join-Path $buildRoot "apps\control_console"

New-Item -ItemType Directory -Path $buildRoot -Force | Out-Null
robocopy $source $buildRoot /E /XD build .dart_tool .gradle releases /NFL /NDL /NJH /NJS | Out-Null

Push-Location $destination
try {
    flutter pub get
    flutter build windows --release
} finally {
    Pop-Location
}

$releaseDestination = Join-Path $source "releases\control_console"
New-Item -ItemType Directory -Path $releaseDestination -Force | Out-Null
robocopy "$destination\build\windows\x64\runner\Release" $releaseDestination /E /NFL /NDL /NJH /NJS | Out-Null

$runtimeDestination = "D:\LujianNativeApps\control_console"
New-Item -ItemType Directory -Path $runtimeDestination -Force | Out-Null
robocopy "$destination\build\windows\x64\runner\Release" $runtimeDestination /E /NFL /NDL /NJH /NJS | Out-Null
Write-Output "Built: $runtimeDestination\lujian_control_console.exe"
