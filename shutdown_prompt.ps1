Add-Type -AssemblyName PresentationFramework

$timeoutSeconds = 300
$confirmation = New-Object -TypeName System.Windows.MessageBoxButton -ArgumentList @( 'Yes', 'No', 'Timeout' )
$modalResult = [System.Windows.MessageBox]::Show('Do you want to terminate the instance?', 'Termination Confirmation', $confirmation, [System.Windows.MessageBoxImage]::Question, [System.Windows.MessageBoxResult]::Timeout, ($timeoutSeconds * 1000))

if ($modalResult -eq 'Yes' -or $modalResult -eq 'Timeout') {
    $instance_id = (Invoke-WebRequest -Uri 'http://169.254.169.254/latest/meta-data/instance-id').Content
    aws ec2 terminate-instances --instance-ids $instance_id
}
