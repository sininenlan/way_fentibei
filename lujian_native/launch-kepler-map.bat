@echo off
cd /d "%~dp0kepler_map"
if not exist "node_modules" (
    call npm install
)
if not exist "dist" (
    call npm run build
)
start "" "http://localhost:4174"
call npm start
