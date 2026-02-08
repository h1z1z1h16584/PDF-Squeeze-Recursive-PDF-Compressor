@echo off
cd /d "%~dp0"
powershell -ExecutionPolicy Bypass -File "CompressPDF.ps1"
exit