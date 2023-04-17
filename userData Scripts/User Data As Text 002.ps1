<powershell>
# Set destination folder and log file path
$destination = "C:\Program Files\AWS_min_WIN"
$logFilePath = Join-Path $destination "log.txt"

# Check if the destination folder exists, if not create it
if (!(Test-Path $destination)) {
    New-Item -ItemType Directory -Force -Path $destination
}

# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Verify that Chocolatey is installed
do {
    Start-Sleep -Seconds 5
    $chocoInstalled = $null -ne (Get-Command choco -ErrorAction SilentlyContinue)
} while (!$chocoInstalled)

# Install Git using Chocolatey
choco install git -y

# Add a delay to allow Git to be installed
Start-Sleep -Seconds 120

# Refresh the environment variables
refreshenv

# Clone the repository
$repoUrl = "https://github.com/TortoiseWolfe/AWS_min_WIN.git"

try {
    git clone $repoUrl $destination -ErrorAction Stop
} catch {
    Add-Content -Path $logFilePath -Value "Error cloning repository: $_"
}

# Add a delay to allow git clone to finish
Start-Sleep -Seconds 90

# Create the scheduled task to run monitor_inactivity.ps1 at startup
$monitorScriptPath = Join-Path $destination "monitor_inactivity.ps1"
$action = "-ExecutionPolicy Bypass -File `"$monitorScriptPath`""
schtasks.exe /Create /TN "Monitor Inactivity" /TR "powershell.exe $action" /SC ONSTART /RU SYSTEM /RL HIGHEST /F

# Reset Execution Policy
Set-ExecutionPolicy RemoteSigned -Scope Process -Force
</powershell>
