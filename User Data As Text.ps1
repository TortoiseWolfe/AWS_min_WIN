<powershell>
# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Git using Chocolatey
choco install git -y

# Clone the repository
$repoUrl = "https://github.com/TortoiseWolfe/AWS_min_WIN.git"
$destination = "C:\Program Files\AWS_min_WIN"
git clone $repoUrl $destination

# Create the scheduled task to run monitor_inactivity.ps1 at startup
$monitorScriptPath = Join-Path $destination "monitor_inactivity.ps1"
$action = "-ExecutionPolicy Bypass -File `"$monitorScriptPath`""
schtasks.exe /Create /TN "Monitor Inactivity" /TR "powershell.exe $action" /SC ONSTART /RU SYSTEM /RL HIGHEST /F

# Reset Execution Policy
Set-ExecutionPolicy RemoteSigned -Scope Process -Force
</powershell>
