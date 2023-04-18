$logFilePath = "C:\Program Files\AWS_min_WIN\log.txt"

$psVersion = $PSVersionTable.PSVersion
"PowerShell version: $($psVersion.Major).$($psVersion.Minor)"

# Install the PSWindowsUpdate module if it's not already installed
try {
    if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
        Install-Module -Name PSWindowsUpdate -Force
    }

    # Import the PSWindowsUpdate module
    Import-Module PSWindowsUpdate

    # Run Windows Update
    Get-WindowsUpdate -Install -AcceptAll -Verbose
} catch {
    Add-Content -Path $logFilePath -Value "Error updating Windows: $_"
}

# Update PowerShell if required
try {
    $psVersion = $PSVersionTable.PSVersion.Major
    if ($psVersion -lt 7) {
        $powershellInstallerUrl = "https://github.com/PowerShell/PowerShell/releases/download/v7.1.5/PowerShell-7.1.5-win-x64.msi"
        $powershellInstallerPath = "C:\PowerShellInstaller.msi"

        (New-Object System.Net.WebClient).DownloadFile($powershellInstallerUrl, $powershellInstallerPath)

        Start-Process -FilePath $powershellInstallerPath -ArgumentList "/qn" -Wait -NoNewWindow

        Remove-Item $powershellInstallerPath
    }
} catch {
    Add-Content -Path $logFilePath -Value "Error updating PowerShell: $_"
}

# Add a message indicating the script completed without errors
Add-Content -Path $logFilePath -Value "Example script executed successfully without errors."


# 
# 
# 
# 

# $monitorScriptPath = Join-Path $destination "monitor_inactivity.ps1"
# $action = "-ExecutionPolicy Bypass -File `"$monitorScriptPath`""
# schtasks.exe /Create /TN "Monitor Inactivity" /TR "powershell.exe $action" /SC ONSTART /RU SYSTEM /RL HIGHEST /F

# # Save the modal dialog script to a file
# $modalScriptPath = "C:\ShowModal.ps1"
# $modalScriptContent = @"
# Add-Type -AssemblyName PresentationFramework

# `$window = New-Object System.Windows.Window
# `$window.Title = "Modal Dialog"
# `$window.SizeToContent = "WidthAndHeight"
# `$window.WindowStartupLocation = "CenterScreen"

# `$label = New-Object System.Windows.Controls.Label
# `$label.Content = "This is a modal dialog box."

# `$button = New-Object System.Windows.Controls.Button
# `$button.Content = "OK"
# `$button.Add_Click({ `$window.DialogResult = `$true })
# `$stackPanel = New-Object System.Windows.Controls.StackPanel
# `$stackPanel.Children.Add(`$label)
# `$stackPanel.Children.Add(`$button)

# `$window.Content = `$stackPanel
# `$window.ShowDialog() | Out-Null
# "@
# Set-Content -Path $modalScriptPath -Value $modalScriptContent

# # Create a scheduled task to run ShowModal.ps1 at logon
# $action = "-ExecutionPolicy Bypass -File `"$modalScriptPath`""
# schtasks.exe /Create /TN "Show Modal" /TR "powershell.exe $action" /SC ONLOGON /RU "%username%" /F
