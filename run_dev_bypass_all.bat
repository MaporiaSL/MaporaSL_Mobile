@echo off
setlocal

echo Starting backend in auth bypass mode...
start "Backend Bypass" cmd /k "cd /d %~dp0backend && call run_dev_bypass.bat"

echo Waiting for backend startup...
timeout /t 4 > nul

echo Starting mobile app in auth bypass mode...
cd /d %~dp0mobile
call run_dev_bypass.bat

endlocal
