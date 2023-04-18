<powershell>
# Store the log file path in a variable
$logFilePath = "C:\Users\Administrator\install_pwsh_log.txt"

# Get the PowerShell version and store it in a variable
$psVersion = $PSVersionTable.PSVersion
$psVersionMessage = "PowerShell version: $($psVersion.Major).$($psVersion.Minor)"
Add-Content -Path $logFilePath -Value $psVersionMessage

# Try to download and install PowerShell 7
try {
    $installerUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.1.5/PowerShell-7.1.5-win-x64.msi"
    $installerPath = "C:\PowerShellInstaller.msi"
    (New-Object System.Net.WebClient).DownloadFile($installerUrl, $installerPath)
    Start-Process -FilePath $installerPath -ArgumentList "/qn" -Wait -NoNewWindow
} catch {
    Add-Content -Path $logFilePath -Value "Error installing PowerShell 7: $_"
}

# Check if PowerShell 7 was installed successfully
$pwshPath = "$($env:ProgramFiles)\PowerShell\7\pwsh.exe"
if (Test-Path $pwshPath) {
    Add-Content -Path $logFilePath -Value "PowerShell 7 installed successfully"
} else {
    Add-Content -Path $logFilePath -Value "PowerShell 7 installation failed"
}

# Add a message indicating the script completed without errors
Add-Content -Path $logFilePath -Value "install_pwsh script reached the end"
</powershell>