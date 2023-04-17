$inactive_time_threshold_minutes = 1

function Show-Countdown($duration) {
    $start_time = Get-Date
    do {
        $elapsed_time = (Get-Date) - $start_time
        $remaining_time = $duration - $elapsed_time.TotalSeconds
        Write-Host "`rTerminating in $($remaining_time.ToString("N0")) seconds...`t" -NoNewline
        Start-Sleep -Seconds 1
    } while ($elapsed_time.TotalSeconds -lt $duration)
}

Add-Type @'
    using System;
    using System.Runtime.InteropServices;

    public class LastInputInfo {
        [DllImport("user32.dll", SetLastError = false)]
        private static extern bool GetLastInputInfo(ref LASTINPUTINFO plii);

        [StructLayout(LayoutKind.Sequential)]
        private struct LASTINPUTINFO {
            public uint cbSize;
            public uint dwTime;
        }

        public int GetLastInputTime() {
            LASTINPUTINFO lii = new LASTINPUTINFO();
            lii.cbSize = (uint)Marshal.SizeOf(typeof(LASTINPUTINFO));
            GetLastInputInfo(ref lii);
            return lii.dwTime;
        }
    }
'@

while ($true) {
    $last_input_info = New-Object -TypeName LastInputInfo
    $last_input_tick = $last_input_info.GetLastInputTime()
    $idle_time = [timespan]::FromMilliseconds([Environment]::TickCount - $last_input_tick)

    # Calculate and display the remaining time in seconds
    $remaining_time_seconds = ($inactive_time_threshold_minutes * 60) - $idle_time.TotalSeconds
    Write-Host "Remaining time: $($remaining_time_seconds) seconds"

    if ($idle_time.TotalMinutes -ge $inactive_time_threshold_minutes) {
        $instance_id = (Invoke-WebRequest -Uri 'http://169.254.169.254/latest/meta-data/instance-id').Content
        Write-Host "Warning: The instance will be terminated due to inactivity. Press any key to cancel the termination."
        $warning_duration_seconds = 10
        Show-Countdown $warning_duration_seconds
        if (-not $host.UI.RawUI.KeyAvailable) {
            aws ec2 terminate-instances --instance-ids $instance_id
            break
        } else {
            $null = $host.UI.RawUI.ReadKey("IncludeKeyUp,NoEcho")
        }
    }
    Start-Sleep -Seconds 1
}
