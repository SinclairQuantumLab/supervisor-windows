@echo off
REM 2025/03/05 16:19 Created by Joonseok Hur
REM https://chatgpt.com/c/67c8da2b-8ca8-8005-b160-ff42b37a1756

setlocal enabledelayedexpansion

REM === Set your service name here ===
set "SERVICE_NAME=supervisord"

REM Query the service for its PID
set "ServicePID="
for /f "tokens=2 delims=:" %%A in ('sc queryex "%SERVICE_NAME%" ^| findstr "PID"') do set "ServicePID=%%A"

REM Trim spaces
for /f "tokens=* delims= " %%A in ("!ServicePID!") do set "ServicePID=%%A"

REM If PID is empty or 0, service is already stopped
if "%ServicePID%"=="" (
    echo %SERVICE_NAME% is already stopped.
    goto :EOF
)

if "%ServicePID%"=="0" (
    echo %SERVICE_NAME% is already stopped.
    goto :EOF
)

echo Stopping %SERVICE_NAME% (PID: %ServicePID%)...
taskkill /F /PID %ServicePID% >nul 2>&1
if %ERRORLEVEL% neq 0 (
    echo [Error] Failed to stop %SERVICE_NAME%. Ensure you run this as Administrator.
    goto :EOF
)

REM Wait briefly for Windows to update service status
timeout /t 3 >nul

REM Verify service state
sc query "%SERVICE_NAME%" | findstr /C:"STOPPED" >nul && echo %SERVICE_NAME% has been stopped successfully.

endlocal
