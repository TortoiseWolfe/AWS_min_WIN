Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase

Function Show-TimedMessageBox {
    param(
        [string]$Text,
        [string]$Caption,
        [System.Windows.MessageBoxButton]$Buttons,
        [System.Windows.MessageBoxImage]$Image,
        [int]$TimeoutSeconds
    )

    $script:timedMessageBoxResult = $null

    $window = New-Object System.Windows.Window
    $window.Title = $Caption
    $window.SizeToContent = "WidthAndHeight"
    $window.WindowStartupLocation = "CenterScreen"
    $window.ShowInTaskbar = $false
    $window.Topmost = $true

    $label = New-Object System.Windows.Controls.Label
    $label.Content = $Text

    $yesButton = New-Object System.Windows.Controls.Button
    $yesButton.Content = "Yes"
    $yesButton.Add_Click({
        $script:timedMessageBoxResult = [System.Windows.MessageBoxResult]::Yes
        $window.Close()
    })

    $noButton = New-Object System.Windows.Controls.Button
    $noButton.Content = "No"
    $noButton.Add_Click({
        $script:timedMessageBoxResult = [System.Windows.MessageBoxResult]::No
        $window.Close()
    })

    $stackPanel = New-Object System.Windows.Controls.StackPanel
    $stackPanel.Children.Add($label)
    $stackPanel.Children.Add($yesButton)
    $stackPanel.Children.Add($noButton)

    $window.Content = $stackPanel

    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = New-Object System.TimeSpan -ArgumentList 0, 0, $TimeoutSeconds
    $timer.Add_Tick({
        $script:timedMessageBoxResult = [System.Windows.MessageBoxResult]::Timeout
        $timer.Stop()
        $window.Close()
    })
    $timer.Start()

    $window.ShowDialog() | Out-Null

    return $script:timedMessageBoxResult
}

Function Get-LastInputInfo {
    Add-Type -MemberDefinition @"
    [DllImport("user32.dll", SetLastError = false)]
    public static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

    [StructLayout(LayoutKind.Sequential)]
    public struct LASTINPUTINFO {
        public uint cbSize;
        public int dwTime;
    }
"@ -Name "User32" -Namespace "PInvoke" -Using PInvoke.User32

    $lastInputInfo = New-Object PInvoke.User32+LASTINPUTINFO
    $lastInputInfo.cbSize = [System.Runtime.InteropServices.Marshal]::SizeOf($lastInputInfo)
    $result = [PInvoke.User32]::GetLastInputInfo([ref]$lastInputInfo)

    if ($result) {
        return $lastInputInfo.dwTime
    } else {
        throw "Failed to get last input info."
    }
}

Function Get-TickCount {
    Add-Type -MemberDefinition @"
    [DllImport("kernel32.dll", SetLastError = false)]
    public static extern uint GetTickCount();
"@ -Name "Kernel32" -Namespace "PInvoke" -Using PInvoke.Kernel32

    return [PInvoke.Kernel32]::GetTickCount()
}

$inactivityThresholdSeconds = 1 * 60 # // 15 minutes
$timeoutSeconds = 1 * 60 # // 5 minutes
$messageBoxText = 'Do you want to terminate the instance?'
$messageBoxTitle = 'Termination Confirmation'
$messageBoxButtons = [System.Windows.MessageBoxButton]::YesNo
$messageBoxImage = [System.Windows.MessageBoxImage]::Question

while ($true) {
    Start-Sleep -Seconds 1
    $idleTime = (Get-TickCount) - (Get-LastInputInfo)
    $idleTimeSeconds = $idleTime / 1000

    if ($idleTimeSeconds -ge $inactivityThresholdSeconds) {
        $modalResult = Show-TimedMessageBox -Text $messageBoxText -Caption $messageBoxTitle -Buttons $messageBoxButtons -Image $messageBoxImage -TimeoutSeconds $timeoutSeconds

        if ($modalResult -eq 'Yes' -or $modalResult -eq 'Timeout') {
            $instance_id = (Invoke-WebRequest -Uri 'http://169.254.169.254/latest/meta-data/instance-id').Content
            aws ec2 terminate-instances --instance-ids $instance_id
            break
        }
    }
}
