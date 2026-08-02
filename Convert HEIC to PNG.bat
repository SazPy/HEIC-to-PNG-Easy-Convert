@echo off
:: Double-click this file to convert all HEIC images in this folder to PNG.
:: No installation required - uses Windows' built-in image codecs via PowerShell.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0convert_heic.ps1"
pause
