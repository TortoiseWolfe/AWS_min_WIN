$inactive_time_threshold_minutes = 1
$shutdown_prompt_script_path = "C:\Program Files\AWS_min_WIN\shutdown_prompt.ps1"

while ($true) {
    $current_time = Get-Date
    if ($current_time.Hour -ge 7) {
        $last_input_info = New-Object -TypeName 'PowerShellGet.LastInputInfo'
        $last_input_tick = $last_input_info.GetLastInputTime()
        $idle_time = [timespan]::FromMilliseconds([Environment]::TickCount - $last_input_tick)

        if ($idle_time.TotalMinutes -ge $inactive_time_threshold_minutes) {
            . $shutdown_prompt_script_path
        }
    }
    Start-Sleep -Seconds 60
}
