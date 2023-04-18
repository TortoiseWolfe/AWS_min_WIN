<powershell># Set the path for the log file
# Set the path for the log file
$logFilePath = "C:\Users\Administrator\script_log.txt"

# Check if the user has permission to write to the log file
try {
    $null = New-Item -Path $logFilePath -ItemType File -Force
} catch {
    $fallbackLogPath = "$($env:USERPROFILE)\fallback_script_log.txt"
    try {
        $null = New-Item -Path $fallbackLogPath -ItemType File -Force
        $logFilePath = $fallbackLogPath
    } catch {
        Write-Host "Unable to write to the log file or fallback log file. Make sure you have the necessary permissions."
        exit 1
    }
    Add-Content -Path $logFilePath -Value "Unable to write to the log file. Using fallback log file: $_"
}

# Get the PowerShell version and store it in a variable
$psVersion = $PSVersionTable.PSVersion
$psVersionMessage = "PowerShell version: $($psVersion.Major).$($psVersion.Minor)"
Add-Content -Path $logFilePath -Value $psVersionMessage

if ($psVersion.Major -lt 7) {
    # Try to download and install PowerShell 7 using the ZIP package
    try {
        $zipUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.2.1/PowerShell-7.2.1-win-x64.zip"
        $zipPath = "C:\PowerShellZip.zip"
        $extractPath = "C:\PowerShell7"

        (New-Object System.Net.WebClient).DownloadFile($zipUrl, $zipPath)
        Expand-Archive -Path $zipPath -DestinationPath $extractPath

        # Add PowerShell 7 folder to the system PATH
        $env:Path += ";$extractPath"
        [Environment]::SetEnvironmentVariable("Path", $env:Path, [System.EnvironmentVariableTarget]::Machine)

    } catch {
        Add-Content -Path $logFilePath -Value "Error installing PowerShell 7: $_"
    }

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
    $elapsedTime = [int](Get-Date - $startTime).TotalSeconds
    $remainingTime = 60 - $elapsedTime
    $label.Content = "Time remaining: $remainingTime seconds"

    if ($remainingTime -le 0) {
        $timer.Stop()
        $window.Close()
    }
})

$timer.Start()
$window.ShowDialog()
</powershell>