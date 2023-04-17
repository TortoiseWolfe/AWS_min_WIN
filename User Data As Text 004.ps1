<powershell>
# Set destination folder and log file path
$destination = "C:\Program Files\AWS_min_WIN"
$logFilePath = Join-Path $destination "log.txt"

# Check if the destination folder exists, if not create it
if (!(Test-Path $destination)) {
    New-Item -ItemType Directory -Force -Path $destination
}

Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

# Update PowerShell if required
$psVersion = $PSVersionTable.PSVersion.Major
if ($psVersion -lt 7) {
    $powershellInstallerUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.1.5/PowerShell-7.1.5-win-x64.msi"
    $powershellInstallerPath = "C:\PowerShellInstaller.msi"

    (New-Object System.Net.WebClient).DownloadFile($powershellInstallerUrl, $powershellInstallerPath)

    Start-Process -FilePath $powershellInstallerPath -ArgumentList "/qn" -Wait -NoNewWindow

    Remove-Item $powershellInstallerPath
}
# Download and extract the Git repository without installing Git
try {
    $repoUrl = "https://github.com/TortoiseWolfe/AWS_min_WIN/archive/refs/heads/main.zip"
    $repoZipPath = "C:\AWS_min_WIN.zip"
    $repoExtractPath = "C:\AWS_min_WIN"

    (New-Object System.Net.WebClient).DownloadFile($repoUrl, $repoZipPath)

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($repoZipPath, $repoExtractPath)

    # Move the contents of the extracted folder to the destination folder
    $extractedRepoFolder = Join-Path $repoExtractPath "AWS_min_WIN-main"
    Get-ChildItem -Path $extractedRepoFolder | Move-Item -Destination $destination

    # Remove the downloaded zip file and the extracted folder
    Remove-Item $repoZipPath
    Remove-Item $repoExtractPath -Recurse
} catch {
    Add-Content -Path $logFilePath -Value "Error downloading and extracting repository: $_"
}

# $gitInstallerUrl = "https://github.com/git-for-windows/git/releases/download/v2.33.0.windows.2/Git-2.33.0.2-64-bit.exe"
# $gitInstallerPath = "C:\GitInstaller.exe"

# (New-Object System.Net.WebClient).DownloadFile($gitInstallerUrl, $gitInstallerPath)

# Start-Process -FilePath $gitInstallerPath -ArgumentList "/VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /NOICONS /COMPONENTS=assoc,assoc_sh" -Wait -NoNewWindow

# Remove-Item $gitInstallerPath

# $repoUrl = "https://github.com/TortoiseWolfe/AWS_min_WIN.git"

# try {
#     git clone $repoUrl $destination -ErrorAction Stop
# } catch {
#     Add-Content -Path $logFilePath -Value "Error cloning repository: $_"
# }

# Start-Sleep -Seconds 90

$monitorScriptPath = Join-Path $destination "monitor_inactivity.ps1"
$action = "-ExecutionPolicy Bypass -File `"$monitorScriptPath`""
schtasks.exe /Create /TN "Monitor Inactivity" /TR "powershell.exe $action" /SC ONSTART /RU SYSTEM /RL HIGHEST /F

# Save the modal dialog script to a file
$modalScriptPath = "C:\ShowModal.ps1"
$modalScriptContent = @"
Add-Type -AssemblyName PresentationFramework

`$window = New-Object System.Windows.Window
`$window.Title = "Modal Dialog"
`$window.SizeToContent = "WidthAndHeight"
`$window.WindowStartupLocation = "CenterScreen"

`$label = New-Object System.Windows.Controls.Label
`$label.Content = "This is a modal dialog box."

`$button = New-Object System.Windows.Controls.Button
`$button.Content = "OK"
`$button.Add_Click({ `$window.DialogResult = `$true })

`$stackPanel = New-Object System.Windows.Controls.StackPanel
`$stackPanel.Children.Add(`$label)
`$stackPanel.Children.Add(`$button)

`$window.Content = `$stackPanel
`$window.ShowDialog() | Out-Null
"@
Set-Content -Path $modalScriptPath -Value $modalScriptContent

# Create a scheduled task to run ShowModal.ps1 at logon
$action = "-ExecutionPolicy Bypass -File `"$modalScriptPath`""
schtasks.exe /Create /TN "Show Modal" /TR "powershell.exe $action" /SC ONLOGON /RU "%username%" /F

Set-ExecutionPolicy RemoteSigned -Scope Process -Force
</powershell>
