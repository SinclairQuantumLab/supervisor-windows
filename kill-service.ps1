# kill-service.ps1
#
# Kill the process behind a Windows Service.
#
# Run this from PowerShell started with "Run as administrator".

# param lets this script accept a service name and -Yes.
param(
    # First plain argument. Service Name or DisplayName. If omitted, the script asks.
    [string]$ServiceName = "",

    # Kill without asking for YES. -Force and -y also work.
    [Alias("Yes", "y")]
    [switch]$Force
)

# If anything errors, stop the script instead of continuing half-done.
$ErrorActionPreference = "Stop"

# Step 1. Make sure this shell is running as admin.
$identity = [Security.Principal.WindowsIdentity]::GetCurrent()
$principal = [Security.Principal.WindowsPrincipal]::new($identity)
$isAdmin = $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    throw 'Run PowerShell with "Run as administrator", then run this script again.'
}

if (-not $ServiceName) {
    Write-Host "No service name was given."
    Write-Host "Run Get-Service in another PowerShell if you need to check the exact Name."
    $ServiceName = Read-Host "Service name to kill"
}

if (-not $ServiceName) {
    Write-Host "Cancelled. No service name was given."
    return
}

# Step 2. Find the service by exact name.
$selectedService = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue

if (-not $selectedService) {
    $selectedService = Get-Service -DisplayName $ServiceName -ErrorAction SilentlyContinue
}

if (-not $selectedService) {
    Write-Error "Service not found: $ServiceName. Run Get-Service and use the exact Name or DisplayName."
    return
}

# Step 3. Find the service process ID.
$service = Get-CimInstance Win32_Service |
    Where-Object { $_.Name -eq $selectedService.Name } |
    Select-Object -First 1

if (-not $service) {
    Write-Error "Could not load Win32_Service details for: $ServiceName"
    return
}

Write-Host "Found service: $($service.Name)"
Write-Host "Display name : $($service.DisplayName)"
Write-Host "State        : $($service.State)"
Write-Host "Service type : $($service.ServiceType)"
Write-Host "Path         : $($service.PathName)"
Write-Host "PID          : $($service.ProcessId)"

# Step 4. If there is no PID, there is nothing to kill.
if (-not $service.ProcessId -or $service.ProcessId -le 0) {
    Write-Host "Service has no running PID. Nothing to kill."
    return
}

# Step 5. Show the exact process before killing it.
$process = Get-CimInstance Win32_Process -Filter "ProcessId = $($service.ProcessId)"

if (-not $process) {
    Write-Host "Service PID $($service.ProcessId) is no longer running."
    return
}

if ($service.ServiceType -notlike "*Own Process*") {
    Write-Warning "This service may share its process with another service. Killing PID $($service.ProcessId) may affect both."
}

$label = "service '$($service.Name)' -> $($process.Name) PID $($process.ProcessId)"
Write-Host "Will kill: $label"
Write-Host "CommandLine   : $($process.CommandLine)"

# Step 6. Kill only this service process.
# Without -Yes/-Force/-y, require a typed YES.
$shouldStop = $Force

if (-not $shouldStop) {
    $answer = Read-Host "Type YES to kill $label"
    $shouldStop = ($answer -eq "YES")
}

if (-not $shouldStop) {
    Write-Host "Cancelled. No process was killed."
    return
}

Stop-Process -Id $process.ProcessId -Force -ErrorAction SilentlyContinue

Start-Sleep -Seconds 1

$remaining = Get-CimInstance Win32_Process -Filter "ProcessId = $($process.ProcessId)" -ErrorAction SilentlyContinue
if ($remaining) {
    Write-Host "Killing $($process.Name) (PID $($process.ProcessId)) FAIL"
    Write-Warning "PID $($process.ProcessId) is still visible. Check Task Manager or rerun this script."
} else {
    Write-Host "Killing $($process.Name) (PID $($process.ProcessId)) SUCCESS"
}
