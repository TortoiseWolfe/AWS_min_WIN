Add-Type -AssemblyName PresentationFramework

$window = New-Object System.Windows.Window
$window.Title = "Modal Dialog"
$window.SizeToContent = "WidthAndHeight"
$window.WindowStartupLocation = "CenterScreen"

$label = New-Object System.Windows.Controls.Label
$label.Content = "This is a modal dialog box."

$timerLabel = New-Object System.Windows.Controls.Label

$button = New-Object System.Windows.Controls.Button
$button.Content = "OK"
$button.Add_Click({ $window.DialogResult = $true })

$stackPanel = New-Object System.Windows.Controls.StackPanel
$stackPanel.Children.Add($label)
$stackPanel.Children.Add($timerLabel)
$stackPanel.Children.Add($button)

$window.Content = $stackPanel

$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(1)

$initialTime = 2 * 60 # Set the countdown time in seconds (e.g., 2 minutes)
$remainingTime = $initialTime

$timer.Add_Tick({
    $remainingTime--
    $minutes = [int]($remainingTime / 60)
    $seconds = $remainingTime % 60
    $timerLabel.Content = "{0:D2}:{1:D2}" -f $minutes, $seconds

    Write-Host "Remaining time: $remainingTime"

    if ($remainingTime -le 0) {
        Write-Host "Timer has stopped"
        $timer.Stop()
        $window.DialogResult = $true
    }
})

# $timer.Start()
# $window.ShowDialog() | Out-Null
# if ($window.DialogResult -eq $true) {
