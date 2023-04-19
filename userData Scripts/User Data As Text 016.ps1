<powershell>
function CreateLogFile {
    param($logFilePath, $fallbackLogPath)

    try {
        $null = New-Item -Path $logFilePath -ItemType File -Force
    } catch {
        try {
            $null = New-Item -Path $fallbackLogPath -ItemType File -Force
            $logFilePath = $fallbackLogPath
        } catch {
            Write-Host "Unable to write to the log file or fallback log file. Make sure you have the necessary permissions."
            exit 1
        }
        Add-Content -Path $logFilePath -Value "Unable to write to the log file. Using fallback log file: $_"
    }

    return $logFilePath
}

function InstallPowerShell7 {
    param($zipUrl, $zipPath, $extractPath, $logFilePath)

    try {
        (New-Object System.Net.WebClient).DownloadFile($zipUrl, $zipPath)
        Expand-Archive -Path $zipPath -DestinationPath $extractPath

        # Add PowerShell 7 folder to the system PATH
        $env:Path += ";$extractPath"
        [Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)

    } catch {
        Add-Content -Path $logFilePath -Value "Error installing PowerShell 7: $_"
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
    # Download and install PowerShell 7
    $zipUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x64.zip"
    $zipPath = "C:\PowerShellZip.zip"
    $extractPath = "C:\PowerShell7"
    
    InstallPowerShell7 -zipUrl $zipUrl -zipPath $zipPath -extractPath $extractPath -logFilePath $logFilePath

    # Check if PowerShell 7 was installed successfully
    $pwshPath = "C:\PowerShell7\pwsh.exe"
    if (Test-Path $pwshPath) {
        Add-Content -Path $logFilePath -Value "PowerShell 7 installed successfully"
        & $pwshPath -Command { 
            . $args[0]
        } -args $MyInvocation.MyCommand.Path
        exit
    } else {
        Add-Content -Path $logFilePath -Value "PowerShell 7 installation failed"
        Write-Host "PowerShell 7 installation failed. Please run this script in PowerShell 7 or higher."
        exit 1
    }
}

# Check if the destination folder exists, if not create it
if (!(Test-Path $destination)) {
    New-Item -ItemType Directory -Force -Path $destination
}

# Set the execution policy to bypass the current scope
Set-ExecutionPolicy Bypass -Scope Process -Force

# [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# Download and extract the repository without installing Git
try {
    $repoUrl = "https://github.com/TortoiseWolfe/AWS_min_WIN/archive/refs/heads/main.zip"
    $repoZipPath = "C:\AWS_min_WIN.zip"
    $repoExtractPath = "C:\AWS_min_WIN"

    # Download the zip file from the repository URL
    (New-Object System.Net.WebClient).DownloadFile($repoUrl, $repoZipPath)

    # Extract the contents of the zip file
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($repoZipPath, $repoExtractPath)

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

# Run the example_script.ps1 file from the repo
$exampleScriptPath = Join-Path $destination "example_script.ps1"
$ps7Executable = "C:\PowerShell7\pwsh.exe"

if (Test-Path $exampleScriptPath) {
    try {
        # Execute the example_script.ps1 file using PowerShell 7
        Start-Process -FilePath $ps7Executable -ArgumentList "-ExecutionPolicy Bypass -File `"$exampleScriptPath`"" -NoNewWindow
    } catch {
        # Log any errors encountered while running the example_script.ps1 file
        Add-Content -Path $logFilePath -Value "Error running example_script.ps1: $_"
    }
} else {
    # Log an error if the example_script.ps1 file is not found in the repository
    Add-Content -Path $logFilePath -Value "Error: example_script.ps1 not found in the repository"
}

# Display a pop-up modal with a 60-second countdown
# Clone a GitHub repository
# Install Git
# Check if Git is installed
# Display a pop-up modal with a 60-second countdown
# Reset the execution policy to RemoteSigned
Set-ExecutionPolicy RemoteSigned -Scope Process -Force
</powershell>