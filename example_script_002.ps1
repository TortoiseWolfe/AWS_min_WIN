# Set the path for the log file
$logFilePath = "C:\Program Files\AWS_min_WIN\example_script_log.txt"

# Get the PowerShell version and add it to the log file
$psVersion = $PSVersionTable.PSVersion
$psVersionMessage = "PowerShell version: $($psVersion.Major).$($psVersion.Minor)"
Add-Content -Path $logFilePath -Value $psVersionMessage

# Set the URL and path for the Git installer
$gitInstallerUrl = "https://github.com/git-for-windows/git/releases/download/v2.33.0.windows.2/Git-2.33.0.2-64-bit.exe"
$gitInstallerPath = "C:\GitInstaller.exe"

# Download the Git installer
try {
    (New-Object System.Net.WebClient).DownloadFile($gitInstallerUrl, $gitInstallerPath)
} catch {
    Add-Content -Path $logFilePath -Value "Error downloading Git installer: $_"
}

# Run the Git installer with silent parameters
try {
    Start-Process -FilePath $gitInstallerPath -ArgumentList "/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /NOICONS /COMPONENTS=assoc,assoc_sh" -Wait -NoNewWindow
} catch {
    Add-Content -Path $logFilePath -Value "Error installing Git: $_"
}

# Remove the Git installer
try {
    Remove-Item $gitInstallerPath
} catch {
    Add-Content -Path $logFilePath -Value "Error removing Git installer: $_"
}

# Add a message indicating the script completed without errors
Add-Content -Path $logFilePath -Value "Example script reached the end"
