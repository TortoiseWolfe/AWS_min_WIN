<powershell>
# Set destination folder and log file path
# $destination = "C:\Users\Administrator"
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

# Install AWS CLI using Chocolatey
choco install awscli -y

# Add a delay to allow Git and AWS CLI to be installed
Start-Sleep -Seconds 120

# Get the Git installation path
$gitPath = (Get-Command git).Path

# Add the Git binary path to the environment variables
$env:Path += ";$(Split-Path $gitPath)"

# Refresh the environment variables
refreshenv

# Clone the repository
$repoUrl = "https://github.com/TortoiseWolfe/AWS_min_WIN.git"

try {
    git clone $repoUrl $destination -ErrorAction Stop
} catch {
    Add-Content -Path $logFilePath -Value "Error cloning repository: $_"
}

# Create the scheduled task to run monitor_inactivity.ps1 at startup
$monitorScriptPath = Join-Path $destination "monitor_inactivity.ps1"
$action = "-ExecutionPolicy Bypass -File `"$monitorScriptPath`""
schtasks.exe /Create /TN "Monitor Inactivity" /TR "powershell.exe $action" /SC ONSTART /RU SYSTEM /RL HIGHEST /F

# Reset Execution Policy
Set-ExecutionPolicy RemoteSigned -Scope Process -Force
</powershell>