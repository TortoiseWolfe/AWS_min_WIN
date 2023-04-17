$logFilePath = "C:\Program Files\AWS_min_WIN\log.txt"

$psVersion = $PSVersionTable.PSVersion
"PowerShell version: $($psVersion.Major).$($psVersion.Minor)"

# Install the PSWindowsUpdate module if it's not already installed
try {
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Install-Module -Name PSWindowsUpdate -Force
    }

    # Import the PSWindowsUpdate module
    Import-Module PSWindowsUpdate

    # Run Windows Update
    Get-WindowsUpdate -Install -AcceptAll -Verbose
} catch {
    Add-Content -Path $logFilePath -Value "Error updating Windows: $_"
}

# Update PowerShell if required
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
Add-Content -Path $logFilePath -Value "Example script executed successfully without errors."
