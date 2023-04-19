Add-Type -AssemblyName PresentationFramework

function LoadXaml {
    param([string]$XamlPath)

    [System.Xml.XmlReader]::Create((Get-Item $XamlPath).FullName) | %{ $reader = $_; [System.Windows.Markup.XamlReader]::Load($_) }
}

$window = LoadXaml -XamlPath ".\TimedMessageBox.xaml"
$yesButton = $window.FindName("YesButton")
$noButton = $window.FindName("NoButton")
$timerLabel = $window.FindName("CountdownLabel")

$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = New-Object System.TimeSpan -ArgumentList 0, 0, 1
$remainingTime = 300

$timer.Add_Tick({
    $remainingTime -= 1
    $timerLabel.Content = "Time remaining: $($remainingTime) seconds"

    if ($remainingTime -le 0) {
        $window.DialogResult = $false
        $timer.Stop()
        $window.Close()
    }
})

$yesButton.Add_Click({
    $window.DialogResult = $true
    $timer.Stop()
    $window.Close()
})

$noButton.Add_Click({
    $window.DialogResult = $false
    $timer.Stop()
    $window.Close()
})

$timer.Start()
$result = $window.ShowDialog()

if ($result) {
    $instance_id = (Invoke-WebRequest -Uri 'http://169.254.169.254/latest/meta-data/instance-id').Content
    aws ec2 terminate-instances --instance-ids $instance_id
}
