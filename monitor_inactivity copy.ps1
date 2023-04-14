$inactive_time_threshold_seconds = 30
$shutdown_prompt_script_path = "C:\Program Files\AWS_min_WIN\shutdown_prompt.ps1"

while ($true) {
    $current_time = Get-Date
    if ($current_time.Hour -ge 7) {
        $last_input_info = New-Object -TypeName 'PowerShellGet.LastInputInfo'
        $last_input_tick = $last_input_info.GetLastInputTime()
        $idle_time = [timespan]::FromMilliseconds([Environment]::TickCount - $last_input_tick)

        # Print the current idle time for testing purposes
        Write-Host "Current idle time: $($idle_time.ToString())"

        if ($idle_time.TotalSeconds -ge $inactive_time_threshold_seconds) {
            . $shutdown_prompt_script_path
        }
    }
    Start-Sleep -Seconds 1
}
