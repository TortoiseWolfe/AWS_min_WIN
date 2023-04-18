$logFilePath = "C:\Program Files\AWS_min_WIN\update_Windows_log.txt"

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

    $updates = Get-WindowsUpdate -AcceptAll -Verbose
    foreach ($update in $updates) {
        $updateMessage = "Installing update: $($update.Title)"
        Add-Content -Path $logFilePath -Value $updateMessage
        Install-WindowsUpdate -Update $update -Verbose
    }
    
    # Restart the computer after installing Windows Updates and wait for the restart to complete
    Restart-Computer -Force -Wait
} catch {
    Add-Content -Path $logFilePath -Value "Error updating Windows: $_"
}

# Add a message indicating the script completed without errors
Add-Content -Path $logFilePath -Value "update_Windows script reached the end"
