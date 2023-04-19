<powershell>
# Helper functions
function DownloadFile {
    param($url, $destinationPath)
    Invoke-WebRequest -Uri $url -OutFile $destinationPath
}

function ExtractZip {
    param($zipPath, $destinationPath)
    Expand-Archive -Path $zipPath -DestinationPath $destinationPath
}

function RunScriptWithPwsh7 {
    param($scriptPath, $logFilePath)
    $ps7Executable = "C:\PowerShell7\pwsh.exe"

    if (Test-Path $scriptPath) {
        try {
            Start-Process -FilePath $ps7Executable -ArgumentList "-ExecutionPolicy Bypass -File `"$scriptPath`"" -NoNewWindow
        } catch {
            Add-Content -Path $logFilePath -Value "Error running $scriptPath: $_"
        }
    } else {
        Add-Content -Path $logFilePath -Value "Error: $scriptPath not found in the repository"
    }
}

# Main script starts here

# Set destination folder and log file path
$destination = "C:\Program Files\AWS_min_WIN"
$logFilePath = "C:\Users\Administrator\user_Data_admin_LOG.txt"
$fallbackLogPath = "$($env:USERPROFILE)\fallback_script_log.txt"

# Check if the user has permission to write to the log file
$logFilePath = CreateLogFile -logFilePath $logFilePath -fallbackLogPath $fallbackLogPath

# Get the PowerShell version and store it in a variable
$psVersion = $PSVersionTable.PSVersion
$psVersionMessage = "PowerShell version: $($psVersion.Major).$($psVersion.Minor)"
Add-Content -Path $logFilePath -Value $psVersionMessage

# Rest of the script (PowerShell 7 installation and modal display)
if ($psVersion.Major -lt 7) {
    $zipUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x64.zip"
    $zipPath = "C:\PowerShellZip.zip"
    $extractPath = "C:\PowerShell7"
    
    InstallPowerShell7 -zipUrl $zipUrl -zipPath $zipPath -extractPath $extractPath -logFilePath $logFilePath
    & $pwshPath -Command { 
        . $args[0]
    } -args $MyInvocation.MyCommand.Path
    exit
}

# Check if the destination folder exists, if not create it
if (!(Test-Path $destination)) {
    New-Item -ItemType Directory -Force -Path $destination
}

# Set the execution policy to bypass the current scope
Set-ExecutionPolicy Bypass -Scope Process -Force

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# Download and extract the repository without installing Git
try {
    $repoUrl = "https://github.com/TortoiseWolfe/AWS_min_WIN/archive/refs/heads/main.zip"
    $repoZipPath = "C:\AWS_min_WIN.zip"
    $repoExtractPath = "C:\AWS_min_WIN"

    # Download the zip file from the repository URL
    DownloadFile -url $repoUrl -destinationPath $repoZipPath

    # Extract the contents of the zip file
    ExtractZip -zipPath $repoZipPath -destinationPath $repoExtractPath

    # Move the contents of the extracted folder to the destination folder
    $extractedRepoFolder = Join-Path $repoExtractPath "AWS_min_WIN-main"
    Get-ChildItem -Path $extractedRepoFolder | Move-Item -Destination $destination

    # Remove the downloaded zip file and the extracted folder
    Remove-Item $repoZipPath
    Remove-Item $repoExtractPath -Recurse
} catch {
    # Log any errors encountered while downloading and extracting the repository
    Add-Content -Path $logFilePath -Value "Error downloading and extracting repository: $_"
}

try {
    # Check if NuGet is installed
    if (-not (Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue)) {
        # Install NuGet Package Provider
        Install-PackageProvider -Name NuGet -Force

        # Log a successful installation of NuGet Package Provider
        Add-Content -Path $logFilePath -Value "NuGet Package Provider installed successfully"
    } else {
        # Log if NuGet Package Provider is already installed
        Add-Content -Path $logFilePath -Value "NuGet Package Provider is already installed"
    }
} catch {
    # Log any errors encountered while installing NuGet Package Provider
    Add-Content -Path $logFilePath -Value "Error installing NuGet Package Provider: $_"
}

# Run the example_script.ps1 file from the repo
$exampleScriptPath = Join-Path $destination "example_script.ps1"

RunScriptWithPwsh7 -scriptPath $exampleScriptPath -logFilePath $logFilePath

# Reset the execution policy to RemoteSigned
Set-ExecutionPolicy RemoteSigned -Scope Process -Force
</powershell>