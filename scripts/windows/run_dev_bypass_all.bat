@echo off
setlocal
set REPO_ROOT=%~dp0..\..

echo Starting backend in auth bypass mode...
start "Backend Bypass" cmd /k "cd /d ""%REPO_ROOT%\backend"" && call ""%~dp0backend\run_dev_bypass.bat"""

echo Waiting for backend startup...
timeout /t 4 > nul

echo Starting mobile app in auth bypass mode...
cd /d "%REPO_ROOT%\mobile"
call "%~dp0mobile\run_dev_bypass.bat"

endlocal
