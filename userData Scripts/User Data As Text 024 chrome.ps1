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
function InstallBluebeam {
    param($installerUrl, $logFilePath)

    try {
        $tempInstaller = "C:\temp_bluebeam.exe"
        (New-Object System.Net.WebClient).DownloadFile($installerUrl, $tempInstaller)
        Start-Process -FilePath $tempInstaller -ArgumentList "/quiet", "/lang en-US" -Wait
        Remove-Item $tempInstaller
        Add-Content -Path $logFilePath -Value "Bluebeam installed successfully"
    } catch {
        Add-Content -Path $logFilePath -Value "Error installing Bluebeam: $_"
    }
}
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
}
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
}
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
}
function InstallOffice365 {
    param($odtUrl, $configUrl, $logFilePath)

    try {
        # Download the Office Deployment Tool
        $odtPath = "C:\temp_odt"
        $odtSetupPath = Join-Path $odtPath "setup.exe"
        New-Item -ItemType Directory -Force -Path $odtPath | Out-Null
        (New-Object System.Net.WebClient).DownloadFile($odtUrl, $odtSetupPath)

        # Download the configuration XML
        $configPath = Join-Path $odtPath "configuration.xml"
        (New-Object System.Net.WebClient).DownloadFile($configUrl, $configPath)

        # Install Office 365 using the Office Deployment Tool
        Start-Process -FilePath $odtSetupPath -ArgumentList "/configure $configPath" -Wait

        Add-Content -Path $logFilePath -Value "Office 365 installed successfully"
    } catch {
        Add-Content -Path $logFilePath -Value "Error installing Office 365: $_"
    }
}
function InstallPowerShell7 {
    param($zipUrl, $zipPath, $extractPath, $logFilePath)

    try {
        # Download the PowerShell 7 zip file using the Invoke-WebRequest cmdlet
        Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
        Expand-Archive -Path $zipPath -DestinationPath $extractPath

        # Add PowerShell 7 folder to the system PATH
        [Environment]::SetEnvironmentVariable("Path", "$env:Path;$extractPath", [System.EnvironmentVariableTarget]::Machine)

    } catch {
        Add-Content -Path $logFilePath -Value "Error installing PowerShell 7: $_"
    }
}
function InstallTeamwork {
    param($appName, $installerUrl, $logFilePath)
    
    try {
        $tempInstaller = "C:\temp_$($appName).exe"
        (New-Object System.Net.WebClient).DownloadFile($installerUrl, $tempInstaller)
        Start-Process -FilePath $tempInstaller -ArgumentList "/quiet" -Wait
        Remove-Item $tempInstaller
        Add-Content -Path $logFilePath -Value "$appName installed successfully"
    } catch {
        Add-Content -Path $logFilePath -Value "Error installing $($appName): $_"
    }
    
}
function InstallZoom {
    param($installerUrl, $logFilePath)

    try {
        $tempInstaller = "C:\temp_zoom_installer.exe"
        (New-Object System.Net.WebClient).DownloadFile($installerUrl, $tempInstaller)
        Start-Process -FilePath $tempInstaller -Wait
        Remove-Item $tempInstaller
        Add-Content -Path $logFilePath -Value "Zoom installed successfully"
    } catch {
        Add-Content -Path $logFilePath -Value "Error installing Zoom: $_"
    }
}
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
    
    # Install Bluebeam
    # https://subscription-registration.bluebeam.com/
    # $bluebeamInstallerUrl = "https://downloads.bluebeam.com/software/downloads/20.2.85/BbRevu20.2.85.exe"
    # try {
    #     InstallBluebeam -installerUrl $bluebeamInstallerUrl -logFilePath $logFilePath
    # } catch {
    #     Add-Content -Path $logFilePath -Value "Error installing Bluebeam: $_"
    # }
    
# Install Google Chrome
try {
    $chromeInstallerUrl = "https://dl.google.com/chrome/install/latest/chrome_installer.exe"
    InstallChrome -installerUrl $chromeInstallerUrl -logFilePath $logFilePath
} catch {
    Add-Content -Path $logFilePath -Value "Error installing Google Chrome: $_"
}

    
    # Install Dropbox
    try {
        $dropboxInstallerUrl = "https://www.dropbox.com/download?plat=win&type=full"
        InstallDropbox -installerUrl $dropboxInstallerUrl -logFilePath $logFilePath
    } catch {
        Add-Content -Path $logFilePath -Value "Error installing DropBox: $_"
    }

    # # Install .NET Runtime
    try {
        $dotNetRuntimeInstallerUrl = "https://download.visualstudio.microsoft.com/download/pr/85473c45-8d91-48cb-ab41-86ec7abc1000/83cd0c82f0cde9a566bae4245ea5a65b/windowsdesktop-runtime-6.0.16-win-x64.exe    "
        InstallDotNetRuntime -runtimeInstallerUrl $dotNetRuntimeInstallerUrl -logFilePath $logFilePath
    } catch {
        Add-Content -Path $logFilePath -Value "Error installing .NET Runtime: $_"
    }

    # Install Office 365
    try {
        $odtUrl = "https://download.microsoft.com/download/2/7/A/27AF1BE6-DD20-4CB4-B154-EBAB8A7D4A7E/officedeploymenttool_13426-20308.exe"
        $configUrl = "https://gist.githubusercontent.com/ChatGPT/3c3a735e2a1f8d3296d9ac6f49e6c92e/raw/949b6e114b6ba752b6f1974e8a4d1839e9efadf9/office365_config.xml"
        InstallOffice365 -odtUrl $odtUrl -configUrl $configUrl -logFilePath $logFilePath
    } catch {
        Add-Content -Path $logFilePath -Value "Error installing Office 365: $_"
    }
    
    # Define log file path
    $logFilePath = "C:\teamwork_installation_log.txt"
    
    # Install Teamwork Projects Desktop
    $teamworkProjectsInstallerUrl = "https://tw-open.s3.amazonaws.com/projects/electron/releases/teamwork-projects-desktop.exe"
    InstallTeamwork -appName "Teamwork Projects Desktop" -installerUrl $teamworkProjectsInstallerUrl -logFilePath $logFilePath
    
    # Install Teamwork Chat
    $teamworkChatInstallerUrl = "https://www.teamwork.com/chat-apps" # Replace this with the actual URL when available
    InstallTeamwork -appName "Teamwork Chat" -installerUrl $teamworkChatInstallerUrl -logFilePath $logFilePath
    

    # Install Zoom
    # https://cdn.zoom.us/prod/5.5.12494.0204/ZoomInstaller.exe
    try {
        $zoomInstallerUrl = "https://cdn.zoom.us/prod/5.5.12494.0204/ZoomInstaller.exe"
        InstallZoom -installerUrl $zoomInstallerUrl -logFilePath $logFilePath
    } catch{
        Add-Content -Path $logFilePath -Value "Error installing Zoom: $_"
    }
    
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