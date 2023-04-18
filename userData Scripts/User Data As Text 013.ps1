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
function ShowCountdownModal {
    Add-Type -AssemblyName PresentationFramework
    $window = New-Object System.Windows.Window
    $window.Title = "Countdown"
    $window.Width = 300
    $window.Height = 200
    $window.WindowStartupLocation = [System.Windows.WindowStartupLocation]::CenterScreen

    $label = New-Object System.Windows.Controls.Label
    $label.FontSize = 24
    $label.HorizontalContentAlignment = [System.Windows.HorizontalAlignment]::Center
    $label.VerticalContentAlignment = [System.Windows.VerticalAlignment]::Center
    $window.Content = $label

    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $startTime = Get-Date
    $timer.Interval = [TimeSpan]::FromSeconds(1)

    $timer.Add_Tick({
        $elapsedTime = [int](New-TimeSpan -Start $startTime -End (Get-Date)).TotalSeconds
        $remainingTime = 60 - $elapsedTime
        $label.Content = "Time remaining: $remainingTime seconds"

        if ($remainingTime -le 0) {
            $timer.Stop()
            $window.Close()
        }
    })

    $timer.Start()
    $window.ShowDialog()
}

# Main script starts here
$logFilePath = "C:\Users\Administrator\script_log.txt"
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

# Display a pop-up modal with a 60-second countdown
try {
    ShowCountdownModal
} catch {
    Add-Content -Path $logFilePath -Value "Error displaying countdown modal: $_"
    Write-Host "Error displaying countdown modal: $_"
}
# Clone a GitHub repository
$gitUrl = "https://github.com/TortoiseWolfe/AWS_min_WIN.git"
$repoFolder = "C:\RepoFolder"

# Check if Git is installed
$gitInstalled = Get-Command git -ErrorAction SilentlyContinue
if ($gitInstalled) {
    try {
        git clone $gitUrl $repoFolder
        Add-Content -Path $logFilePath -Value "GitHub repository cloned successfully to $repoFolder"
    } catch {
        Add-Content -Path $logFilePath -Value "Error cloning GitHub repository: $_"
        Write-Host "Error cloning GitHub repository: $_"
    }
} else {
    Add-Content -Path $logFilePath -Value "Git is not installed. Please install Git and try again."
    Write-Host "Git is not installed. Please install Git and try again."
}

</powershell>