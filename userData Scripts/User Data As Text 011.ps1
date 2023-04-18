<powershell>
# Set the path for the log file
$logFilePath = "C:\Program Files\script_log.txt"

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

# Try to download and install PowerShell 7
try {
    # Save the current execution policy
    $currentPolicy = Get-ExecutionPolicy
    # Set the execution policy to unrestricted
    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process -Force

    # Download and install PowerShell 7 from Microsoft repository
    $installScriptUrl = "https://aka.ms/install-powershell.ps1"
    Invoke-Expression "& { $(Invoke-WebRequest -UseBasicParsing -Uri $installScriptUrl) }"

    # Restore the execution policy
    Set-ExecutionPolicy -ExecutionPolicy $currentPolicy -Scope Process -Force
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
</powershell>