# examp_ReBoot.ps1
# Set the log file path
$log_examp_ReBoot_FilePath = "C:\Program Files\AWS_min_WIN\examp_Reboot_log.txt"

# Reboot the instance
try {
    Add-Content -Path $log_examp_ReBoot_FilePath -Value "examp_ReBooting the instance..."
    Restart-Computer -Force
} catch {
    Add-Content -Path $log_examp_ReBoot_FilePath -Value "Error examp_ReBooting the instance: $_"
}
