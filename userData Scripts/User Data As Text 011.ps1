<powershell>
# Set the path for the log file
$logFilePath = "C:\Users\Administrator\script_log.txt"

# Check if the user has permission to write to the log file
try {
    $null = New-Item -Path $logFilePath -ItemType File -Force
} catch {
    $fallbackLogPath = "$($env:USERPROFILE)\fallback_script_log.txt"
    $null = New-Item -Path $fallbackLogPath -ItemType File -Force
    Add-Content -Path $fallbackLogPath -Value "Unable to write to the log file. Make sure you have the necessary permissions: $_"
    exit 1
}

# Get the PowerShell version and store it in a variable
$psVersion = $PSVersionTable.PSVersion
$psVersionMessage = "PowerShell version: $($psVersion.Major).$($psVersion.Minor)"
Add-Content -Path $logFilePath -Value $psVersionMessage

# Try to download and install PowerShell 7 using the ZIP package
try {
    $zipUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x64.zip"
    $zipPath = "C:\PowerShellZip.zip"
    $extractPath = "C:\PowerShell7"

    (New-Object System.Net.WebClient).DownloadFile($zipUrl, $zipPath)
    Expand-Archive -Path $zipPath -DestinationPath $extractPath

    # Add PowerShell 7 folder to the system PATH
    $env:Path += ";$extractPath"
    [Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)

} catch {
    Add-Content -Path $logFilePath -Value "Error installing PowerShell 7: $_"
}

# Check if PowerShell 7 was installed successfully
$pwshPath = "C:\PowerShell7\pwsh.exe"
if (Test-Path $pwshPath) {
    Add-Content -Path $logFilePath -Value "PowerShell 7 installed successfully"
} else {
    Add-Content -Path $logFilePath -Value "PowerShell 7 installation failed"
}

</powershell>