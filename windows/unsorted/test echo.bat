@echo off
REM Save command output in VAR
set STR_CMD=where python
for /f "tokens=*" %%i in ('%STR_CMD%') do set VAR=%%i
echo Output from %STR_CMD% = %VAR%
pause
