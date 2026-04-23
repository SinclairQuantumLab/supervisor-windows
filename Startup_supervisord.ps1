$ErrorActionPreference = "Stop"

# PowerShell script to run supervisord
# independent of the PWD this script is run from.

# script to run
$cmd = ".\.venv\Scripts\supervisord.exe"
$cmdArgs = @("-c", ".\supervisord.conf") 

# move working directory to the project folder
Write-Host ">>> cd to the project directory..."
$projectDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $projectDir
Write-Host "<<< Working directory set to: $PWD"
Write-Host ""


# run supervisord
$cmdstring = "$cmd $($cmdArgs -join ' ')"
Write-Host ">>> Starting app: $cmdstring"
Write-Host ""

& $cmd @cmdArgs
$exitCode = $LASTEXITCODE

Write-Host ""
Write-Host "<<< End of the script: $cmdstring"

exit $exitCode