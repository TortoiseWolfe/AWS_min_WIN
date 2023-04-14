Add-Type -AssemblyName PresentationFramework

$timeoutSeconds = 300
$messageBoxText = 'Do you want to terminate the instance?'
$messageBoxTitle = 'Termination Confirmation'
$messageBoxButtons = [System.Windows.MessageBoxButton]::YesNo
$messageBoxImage = [System.Windows.MessageBoxImage]::Question
$messageBoxDefaultButton = [System.Windows.MessageBoxResult]::Yes
$messageBoxTimeout = $timeoutSeconds * 1000

$modalResult = [System.Windows.MessageBox]::Show($messageBoxText, $messageBoxTitle, $messageBoxButtons, $messageBoxImage, $messageBoxDefaultButton, $messageBoxTimeout)

if ($modalResult -eq 'Yes') {
    $instance_id = (Invoke-WebRequest -Uri 'http://169.254.169.254/latest/meta-data/instance-id').Content
    aws ec2 terminate-instances --instance-ids $instance_id
}
