$logFilePath = "C:\Program Files\AWS_min_WIN\update_WinDowz_log.txt"

$psVersion = $PSVersionTable.PSVersion
$psVersionMessage = "PowerShell version: $($psVersion.Major).$($psVersion.Minor)"
Add-Content -Path $logFilePath -Value $psVersionMessage

# Install NuGet Package Manager if it's not already installed
try {
    if (-not (Get-PackageProvider -Name NuGet -ListAvailable)) {
        Install-PackageProvider -Name NuGet -Force
    }
} catch {
    Add-Content -Path $logFilePath -Value "Error installing NuGet Package Manager: $_"
}

# Install the PSWindowsUpdate module if it's not already installed
try {
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Install-Module -Name PSWindowsUpdate -Force
    }

    # Import the PSWindowsUpdate module
    Import-Module PSWindowsUpdate

    # Run Windows Update
    Get-WindowsUpdate -Install -AcceptAll -Verbose

    # Restart the computer after installing Windows Updates
    Restart-Computer -Force
} catch {
    Add-Content -Path $logFilePath -Value "Error updating Windows: $_"
}

# Add a message indicating the script completed without errors
Add-Content -Path $logFilePath -Value "update_WinDowz script reached the end"
