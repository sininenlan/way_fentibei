$ErrorActionPreference = "Stop"

$source = Resolve-Path (Join-Path $PSScriptRoot "..")
$buildRoot = "D:\lujian_native_build"
$destination = Join-Path $buildRoot "apps\workorder_app"

New-Item -ItemType Directory -Path $buildRoot -Force | Out-Null
robocopy $source $buildRoot /E /XD build .dart_tool .gradle releases /NFL /NDL /NJH /NJS | Out-Null

Push-Location $destination
try {
    flutter pub get
    flutter build apk --debug
} finally {
    Pop-Location
}

$releaseDestination = Join-Path $source "releases\workorder_app"
New-Item -ItemType Directory -Path $releaseDestination -Force | Out-Null
Copy-Item `
    -LiteralPath "$destination\build\app\outputs\flutter-apk\app-debug.apk" `
    -Destination "$releaseDestination\lujian-workorder-debug.apk" `
    -Force
Write-Output "Built: $releaseDestination\lujian-workorder-debug.apk"
