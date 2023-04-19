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
}   # CreateLogFile function creates a log file at the specified path or fallback path.
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
}# InstallPowerShell7 function downloads and installs PowerShell 7 from a specified URL.
function InstallAwsCli {
    param($installerUrl, $logFilePath)

    try {
        $tempInstaller = "C:\temp_awscliv2.msi"
        (New-Object System.Net.WebClient).DownloadFile($installerUrl, $tempInstaller)
        Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i $tempInstaller /quiet" -Wait
        Remove-Item $tempInstaller
        Add-Content -Path $logFilePath -Value "AWS CLI installed successfully"
    } catch {
        Add-Content -Path $logFilePath -Value "Error installing AWS CLI: $_"
    }
}# InstallAwsCli function downloads and installs AWS CLI from a specified URL.

function DownloadAndRunExampleScript {
    param($repoUrl, $repoZipPath, $repoExtractPath, $destination, $logFilePath)

    try {
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

        Add-Content -Path $logFilePath -Value "Repository downloaded and extracted successfully"
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
            Add-Content -Path $logFilePath -Value "Example script executed successfully"
        } catch {
            # Log any errors encountered while running the example_script.ps1 file
            Add-Content -Path $logFilePath -Value "Error running example_script.ps1: $_"
        }
    } else {
        # Log an error if the example_script.ps1 file is not found in the repository
        Add-Content -Path $logFilePath -Value "Error: example_script.ps1 not found in the repository"
    }
}# DownloadAndRunExampleScript function downloads a specified repository and runs the example script.

# Main script starts here
try {
    # Set destination folder and log file path
    $destination = "C:\Users\Administrator\AWS_min_WIN"
    $logFilePath = "C:\Users\Administrator\user_Data_admin_LOG.txt"
    $fallbackLogPath = "$($env:USERPROFILE)\fallback_script_log.txt"

    # Check if the user has permission to write to the log file
    $logFilePath = CreateLogFile -logFilePath $logFilePath -fallbackLogPath $fallbackLogPath

    # Get the PowerShell version and store it in a variable
    $psVersion = $PSVersionTable.PSVersion
    $psVersionMessage = "PowerShell version: $($psVersion.Major).$($psVersion.Minor)"
    Add-Content -Path $logFilePath -Value $psVersionMessage

    if ($psVersion.Major -lt 7) {
        # Download and install PowerShell 7
        $zipUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.3.4/PowerShell-7.3.4-win-x64.zip"
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

    # Install AWS CLI
    $awsCliInstallerUrl = "https://awscli.amazonaws.com/AWSCLIV2.msi"
    InstallAwsCli -installerUrl $awsCliInstallerUrl -logFilePath $logFilePath

    # Check if the destination folder exists, if not create it
    if (!(Test-Path $destination)) {
        New-Item -ItemType Directory -Force -Path $destination
    }

    # Set the execution policy to bypass the current scope
    Set-ExecutionPolicy Bypass -Scope Process -Force

    # Enable TLS 1.2 as a security protocol
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

    # Download and extract the repository without installing Git
    $repoUrl = "https://github.com/TortoiseWolfe/AWS_min_WIN/archive/refs/heads/main.zip"
    $repoZipPath = "C:\AWS_min_WIN.zip"
    $repoExtractPath = "C:\AWS_min_WIN"

    DownloadAndRunExampleScript -repoUrl $repoUrl -repoZipPath $repoZipPath -repoExtractPath $repoExtractPath -destination $destination -logFilePath $logFilePath

    # Reset the execution policy to RemoteSigned
    Set-ExecutionPolicy RemoteSigned -Scope Process -Force

} catch {
    # Log any errors encountered while running the script
    Add-Content -Path $logFilePath -Value "Error running script: $_"
}
# Reset the execution policy to RemoteSigned
Set-ExecutionPolicy RemoteSigned -Scope Process -Force
</powershell>