# Set destination folder and log file path
$destination = "C:\Program Files\AWS_min_WIN"
$logFilePath = Join-Path $destination "log.txt"

# Check if the destination folder exists, if not create it
if (!(Test-Path $destination)) {
    New-Item -ItemType Directory -Force -Path $destination
}

Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

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

# Run the example_script.ps1 file from the repo
$exampleScriptPath = Join-Path $destination "example_script.ps1"
if (Test-Path $exampleScriptPath) {
    try {
        $taskName = "Run Example Script"
        $action = "-ExecutionPolicy Bypass -File `"$exampleScriptPath`""
        schtasks.exe /Create /TN $taskName /TR "powershell.exe $action" /SC ONCE /ST 00:00 /RU SYSTEM /RL HIGHEST /F
        schtasks.exe /Run /TN $taskName
        schtasks.exe /Delete /TN $taskName /F
    } catch {
        Add-Content -Path $logFilePath -Value "Error running example_script.ps1: $_"
    }
} else {
    Add-Content -Path $logFilePath -Value "Error: example_script.ps1 not found in the repository"
}

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
Add-Content -Path $logFilePath -Value "Script executed successfully without errors."
</powershell>
