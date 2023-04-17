Add-Type -AssemblyName PresentationFramework

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

$timeoutSeconds = 300
$messageBoxText = 'Do you want to terminate the instance?'
$messageBoxTitle = 'Termination Confirmation'
$messageBoxButtons = [System.Windows.MessageBoxButton]::YesNo
$messageBoxImage = [System.Windows.MessageBoxImage]::Question

$modalResult = Show-TimedMessageBox -Text $messageBoxText -Caption $messageBoxTitle -Buttons $messageBoxButtons -Image $messageBoxImage -TimeoutSeconds $timeoutSeconds

if ($modalResult -eq 'Yes' -or $modalResult -eq 'Timeout') {
    $instance_id = (Invoke-WebRequest -Uri 'http://169.254.169.254/latest/meta-data/instance-id').Content
    aws ec2 terminate-instances --instance-ids $instance_id
}
