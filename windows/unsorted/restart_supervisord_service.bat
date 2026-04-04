@echo off
REM 2025/03/05 16:19 Created by Joonseok Hur
REM https://chatgpt.com/c/67c8da2b-8ca8-8005-b160-ff42b37a1756

setlocal enabledelayedexpansion

REM --- Call the kill script from the same folder ---
call "%~dp0kill_supervisord_service.bat"

REM --- Wait briefly to allow the service to fully stop ---
timeout /t 3 >nul

REM --- Start the service silently ---
echo Starting %SERVICE_NAME%...
sc start supervisord >nul 2>&1

REM --- Wait until the service state becomes RUNNING ---
echo Waiting for supervisord to reach RUNNING state...
:WaitForRunning
for /f "tokens=4" %%A in ('sc queryex "supervisord" ^| findstr /C:"STATE"') do (
    set "state=%%A"
)
REM The fourth token is the state description (e.g., START_PENDING, RUNNING)
if /I not "%state%"=="RUNNING" (
    timeout /t 2 >nul
    goto :WaitForRunning
)

REM --- Once RUNNING, display the service details ---
echo Service is now RUNNING:
sc queryex "supervisord"

endlocal
