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

    $showMessageBoxDelegate = [System.Windows.Threading.DispatcherOperationCallback] {
        param($ignore)

        $script:timedMessageBoxResult = [System.Windows.MessageBox]::Show($Text, $Caption, $Buttons, $Image)
        $true
    }

    $closeMessageBoxDelegate = [System.Windows.Threading.DispatcherOperationCallback] {
        param($ignore)

        if ($script:timedMessageBoxResult -eq $null) {
            [System.Windows.MessageBox]::Show($Text, $Caption, $Buttons, $Image).Close()
        }
        $true
    }

    $dispatcher = [System.Windows.Threading.Dispatcher]::CurrentDispatcher

    $showMessageBoxOperation = $dispatcher.BeginInvoke($showMessageBoxDelegate, [System.Windows.Threading.DispatcherPriority]::Normal, $null)
    $closeMessageBoxOperation = $dispatcher.BeginInvoke($closeMessageBoxDelegate, [System.Windows.Threading.DispatcherPriority]::Normal, $null)

    $timeout = New-Object -TypeName System.TimeSpan -ArgumentList 0, 0, $TimeoutSeconds
    $dispatcher.InvokeShutdown()

    if (!$showMessageBoxOperation.Wait($timeout)) {
        $script:timedMessageBoxResult = [System.Windows.MessageBoxResult]::Timeout
    }

    $closeMessageBoxOperation.Wait()

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
