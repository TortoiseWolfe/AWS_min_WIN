# Set the path for the log file
$logFilePath = "C:\Program Files\AWS_min_WIN\example_script_log.txt"

# Get the PowerShell version and add it to the log file
$psVersion = $PSVersionTable.PSVersion
$psVersionMessage = "PowerShell version: $($psVersion.Major).$($psVersion.Minor)"
Add-Content -Path $logFilePath -Value $psVersionMessage

# Set the URL and path for the Git installer
$gitInstallerUrl = "https://github.com/git-for-windows/git/releases/download/v2.33.0.windows.2/Git-2.33.0.2-64-bit.exe"
$gitInstallerPath = "C:\GitInstaller.exe"

# Download the Git installer and run it with silent parameters
(New-Object System.Net.WebClient).DownloadFile($gitInstallerUrl, $gitInstallerPath)
Start-Process -FilePath $gitInstallerPath -ArgumentList "/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /NOICONS /COMPONENTS=assoc,assoc_sh" -Wait -NoNewWindow
Remove-Item $gitInstallerPath

# Update PowerShell if required
try {
    $psVersion = $PSVersionTable.PSVersion.Major
    if ($psVersion -lt 7) {
        $powershellInstallerUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.1.5/PowerShell-7.1.5-win-x64.msi"
        $powershellInstallerPath = "C:\PowerShellInstaller.msi"

        (New-Object System.Net.WebClient).DownloadFile($powershellInstallerUrl, $powershellInstallerPath)

        # Check file size and hash
        $expectedFileSize = 97464320
        $expectedHash = "A0A62E2A0FA1C56A8A3D3C3F0E9A00FDAA36AC8A372A0E6D2B0C1FDC5A5E5E5A"
        $actualFileSize = (Get-Item $powershellInstallerPath).Length
        $actualHash = (Get-FileHash -Path $powershellInstallerPath -Algorithm SHA256).Hash

        if ($actualFileSize -eq $expectedFileSize -and $actualHash -eq $expectedHash) {
            Start-Process -FilePath $powershellInstallerPath -ArgumentList "/qn" -Wait -NoNewWindow
            Remove-Item $powershellInstallerPath
        } else {
            Add-Content -Path $logFilePath -Value "Error: PowerShell installer file size or hash does not match expected values."
            Add-Content -Path $logFilePath -Value "Actual file size: $actualFileSize, expected: $expectedFileSize"
            Add-Content -Path $logFilePath -Value "Actual hash: $actualHash, expected: $expectedHash"
        }
    }
} catch {
    Add-Content -Path $logFilePath -Value "Error updating PowerShell: $_"
}

# Add a message indicating the script completed without errors
Add-Content -Path $logFilePath -Value "powershell script reached the end"
