$logFilePath = "C:\Program Files\AWS_min_WIN\update_PowerShell_log.txt"

$psVersion = $PSVersionTable.PSVersion
$psVersionMessage = "PowerShell version: $($psVersion.Major).$($psVersion.Minor)"
Add-Content -Path $logFilePath -Value $psVersionMessage

Commented out: Update PowerShell if required
try {
    $psVersion = $PSVersionTable.PSVersion.Major
    if ($psVersion -lt 7) {
        $powershellInstallerUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.1.5/PowerShell-7.1.5-win-x64.msi"
        $powershellInstallerPath = "C:\PowerShellInstaller.msi"

        (New-Object System.Net.WebClient).DownloadFile($powershellInstallerUrl, $powershellInstallerPath)

        Start-Process -FilePath $powershellInstallerPath -ArgumentList "/qn" -Wait -NoNewWindow

        Remove-Item $powershellInstallerPath
    }
} catch {
    Add-Content -Path $logFilePath -Value "Error updating PowerShell: $_"
}

# Add a message indicating the script completed without errors
Add-Content -Path $logFilePath -Value "powershell script reached the end"
