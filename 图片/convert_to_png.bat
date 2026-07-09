@echo off
setlocal
cd /d "%~dp0"

if "%~1"=="" (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0convert_to_png.ps1"
) else (
  powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0convert_to_png.ps1" %*
)

pause
