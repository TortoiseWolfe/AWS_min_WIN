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
}# CreateLogFile function creates a log file at the specified path or fallback path.
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
    $ps7Executable = "C:\Program Files\PowerShell7\pwsh.exe"

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
function InstallChrome {
    param($installerUrl, $logFilePath)

    try {
        $tempInstaller = "C:\temp_chrome.exe"
        (New-Object System.Net.WebClient).DownloadFile($installerUrl, $tempInstaller)
        Start-Process -FilePath $tempInstaller -ArgumentList "/silent /install" -Wait
        Remove-Item $tempInstaller
        Add-Content -Path $logFilePath -Value "Google Chrome installed successfully"
    } catch {
        Add-Content -Path $logFilePath -Value "Error installing Google Chrome: $_"
    }
}# InstallChrome function downloads and installs Google Chrome from a specified URL.
function InstallDotNetRuntime {
    param($runtimeInstallerUrl, $logFilePath)

    try {
        $tempInstaller = "C:\temp_dotnet_runtime.exe"
        (New-Object System.Net.WebClient).DownloadFile($runtimeInstallerUrl, $tempInstaller)
        Start-Process -FilePath $tempInstaller -ArgumentList "/install /quiet /norestart" -Wait
        Remove-Item $tempInstaller
        Add-Content -Path $logFilePath -Value ".NET Runtime installed successfully"
    } catch {
        Add-Content -Path $logFilePath -Value "Error installing .NET Runtime: $_"
    }
}# InstallDotNetRuntime function downloads and installs .NET Runtime from a specified URL.
function InstallDropbox {
    param($installerUrl, $logFilePath)

    try {
        $tempInstaller = "C:\temp_dropbox_installer.exe"
        (New-Object System.Net.WebClient).DownloadFile($installerUrl, $tempInstaller)
        Start-Process -FilePath $tempInstaller -ArgumentList "/S" -Wait
        Remove-Item $tempInstaller
        Add-Content -Path $logFilePath -Value "Dropbox installed successfully"
    } catch {
        Add-Content -Path $logFilePath -Value "Error installing Dropbox: $_"
    }
}# InstallDropbox function downloads and installs Dropbox from a specified URL.

function InstallPowerShell7 {
    param($zipUrl, $zipPath, $extractPath, $logFilePath)

    try {
        # Download the PowerShell 7 zip file using the Invoke-WebRequest cmdlet
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
        Expand-Archive -Path $zipPath -DestinationPath $extractPath

        # Add PowerShell 7 folder to the system PATH
        $env:Path += ";$extractPath"
        [Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)

    } catch {
        Add-Content -Path $logFilePath -Value "Error installing PowerShell 7: $_"
    }
}# InstallPowerShell7 function downloads and installs PowerShell 7 from a specified URL.

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
        $zipPath = "C:\Users\Administrator\Downloads\PowerShellZip.zip"
        $extractPath = "C:\Program Files\PowerShell7"
        
        InstallPowerShell7 -zipUrl $zipUrl -zipPath $zipPath -extractPath $extractPath -logFilePath $logFilePath
        
        # Check if PowerShell 7 was installed successfully
        $pwshPath = "C:\Program Files\PowerShell7\pwsh.exe"
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

    # Set the timezone variable
    $timezone = "Eastern Standard Time"
    # Set the timezone on the AWS instance
    Set-TimeZone -Id $timezone
    
    # # Install Bluebeam Revu
    # $bluebeamInstallerUrl = "https://support.bluebeam.com/downloads/revu/windows/revu2020/20.2.30/BluebeamRevu2020.2.30_x64.exe"
    # InstallBluebeam -installerUrl $bluebeamInstallerUrl -logFilePath $logFilePath

    # # Install Google Chrome
    # $chromeInstallerUrl = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
    # InstallChrome -installerUrl $chromeInstallerUrl -logFilePath $logFilePath
    
    # # Install Dropbox
    # try {
    #     $dropboxInstallerUrl = "https://www.dropbox.com/download?plat=win&type=full"
    #     InstallDropbox -installerUrl $dropboxInstallerUrl -logFilePath $logFilePath
    # } catch {
    #     Add-Content -Path $logFilePath -Value "Error installing DropBox: $_"
    # }

    # # # Install .NET Runtime
    # try {
    #     $dotNetRuntimeInstallerUrl = "https://download.visualstudio.microsoft.com/download/pr/85473c45-8d91-48cb-ab41-86ec7abc1000/83cd0c82f0cde9a566bae4245ea5a65b/windowsdesktop-runtime-6.0.16-win-x64.exe    "
    #     InstallDotNetRuntime -runtimeInstallerUrl $dotNetRuntimeInstallerUrl -logFilePath $logFilePath
    # } catch {
    #     Add-Content -Path $logFilePath -Value "Error installing .NET Runtime: $_"
    # }

    # # Install Office 365
    # InstallOffice365 -logFilePath $logFilePath

    # # Install Teamwork
    # # https://tw-open.s3.amazonaws.com/projects/electron/releases/teamwork-projects-desktop.exe
    # # https://www.teamwork.com/chat-apps
    # try {
    #     $teamworkInstallerUrl = "https://tw-open.s3.amazonaws.com/projects/electron/releases/teamwork-projects-desktop.exe"
    #     InstallTeamwork -installerUrl $teamworkInstallerUrl -logFilePath $logFilePath
    # } catch {
    #     Add-Content -Path $logFilePath -Value "Error installing Teamwork Projects Desktop: $_"
    # }

    # # Install Zoom
    # try {
    #     $zoomInstallerUrl = "https://cdn.zoom.us/prod/5.5.12494.0204/ZoomInstaller.exe"
    #     InstallZoom -installerUrl $zoomInstallerUrl -logFilePath $logFilePath
    # } catch{
    #     Add-Content -Path $logFilePath -Value "Error installing Zoom: $_"
    # }
    
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
# Restart-Computer
</powershell>