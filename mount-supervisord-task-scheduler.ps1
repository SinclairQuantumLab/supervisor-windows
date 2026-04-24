# mount-supervisord-task-scheduler.ps1
#
# This script registers the Task Scheduler part of the Windows setup.
# Run it after the repository is cloned.
#
# Run this from PowerShell opened with "Run as administrator".
#
# The task is named `supervisor`. It starts at user logon, runs only when
# that user is logged on, uses highest privileges, and launches
# `Startup_supervisord.ps1` from this repository with the repository folder
# as the working directory.
#
# Startup flow:
#
# Task Scheduler
#   -> Startup_supervisord.ps1
#      -> .venv\Scripts\supervisord.exe -c .\supervisord.conf
#         -> app processes from conf.d\*.conf
#
param(
    # Folder that contains this repository.
    [string]$RepoRoot = $PSScriptRoot,

    # Name shown in Task Scheduler.
    [string]$TaskName = "supervisor",

    # Windows user that should run supervisord.
    [string]$TaskUser = "$env:USERDOMAIN\$env:USERNAME",

    # Start the scheduled task immediately after registration.
    [switch]$RunNow
)

$ErrorActionPreference = "Stop"

# Step 1. Confirm this PowerShell is running as admin.
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    throw 'Run this script from PowerShell started with "Run as administrator".'
}

# Step 2. Use the supervisor folder and the launcher this task will run.
# The Task Scheduler action below will use this folder as its working directory.
if (-not (Test-Path $RepoRoot)) {
    throw "Supervisor folder does not exist: $RepoRoot"
}

$LauncherPath = "$RepoRoot\Startup_supervisord.ps1"

Write-Host ">>> Setting up supervisord user-session task"
Write-Host "Repo root: $RepoRoot"
Write-Host "Task name: $TaskName"
Write-Host "Task user: $TaskUser"
Write-Host ""

# Step 3. Check only the launcher file that Task Scheduler will call directly.
if (-not (Test-Path $LauncherPath)) {
    throw "Missing launcher script: $LauncherPath"
}

# Step 4. Define what Task Scheduler should launch.
# Task Scheduler starts PowerShell in hidden-window mode. That PowerShell then
# runs Startup_supervisord.ps1, which starts supervisord with supervisord.conf.
$PowerShellExe = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
$ActionArgs = @(
    "-NoProfile"
    "-ExecutionPolicy", "Bypass"
    "-WindowStyle", "Hidden"
    "-File", "`"$LauncherPath`""
) -join " "

$Action = New-ScheduledTaskAction `
    -Execute $PowerShellExe `
    -Argument $ActionArgs `
    -WorkingDirectory $RepoRoot

# Step 5. Define when the task starts.
# AtLogOn places supervisord in the user's interactive desktop session.
$Trigger = New-ScheduledTaskTrigger -AtLogOn -User $TaskUser

# Step 6. Run only when this user is logged on.
$Principal = New-ScheduledTaskPrincipal `
    -UserId $TaskUser `
    -LogonType Interactive `
    -RunLevel Highest

# Step 7. Define the task behavior.
# These settings let Windows start the task on demand, retry briefly if the
# task launch fails, and avoid launching duplicate supervisor tasks.
$Settings = New-ScheduledTaskSettingsSet `
    -AllowStartIfOnBatteries `
    -DontStopIfGoingOnBatteries `
    -StartWhenAvailable `
    -MultipleInstances IgnoreNew `
    -RestartCount 3 `
    -RestartInterval (New-TimeSpan -Minutes 1)

$Description = @"
Starts supervisord at user logon inside the interactive desktop session.

This task intentionally uses Task Scheduler instead of a Windows Service so
supervisord and its child processes run in the logged-in user's session.
"@

# Step 8. Register the task.
# -Force updates the existing "supervisor" task if it is already present.
Register-ScheduledTask `
    -TaskName $TaskName `
    -Action $Action `
    -Trigger $Trigger `
    -Principal $Principal `
    -Settings $Settings `
    -Description $Description `
    -Force

Write-Host "<<< Registered task: $TaskName"
Write-Host ""

# Step 9. Optionally start the task now.
# Without -RunNow, the task starts the next time the target user logs in.
if ($RunNow) {
    Write-Host ">>> Starting task now..."
    Start-ScheduledTask -TaskName $TaskName
    Start-Sleep -Seconds 3
}

# Step 10. Print the task status and the next user command.
$Task = Get-ScheduledTask -TaskName $TaskName
$TaskInfo = Get-ScheduledTaskInfo -TaskName $TaskName

Write-Host "Task state: $($Task.State)"
Write-Host "Last run time: $($TaskInfo.LastRunTime)"
Write-Host "Last task result: $($TaskInfo.LastTaskResult)"
Write-Host ""
Write-Host "Check supervisor with:"
Write-Host '  supervisorctl -u "<USERNAME>" -p "<PASSWORD>" status'
