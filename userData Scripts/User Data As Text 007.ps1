# Set destination folder and log file path
$destination = "C:\Program Files\AWS_min_WIN"
$logFilePath = Join-Path $destination "log.txt"

# Check if the destination folder exists, if not create it
if (!(Test-Path $destination)) {
    New-Item -ItemType Directory -Force -Path $destination
}

# Temporarily allows unrestricted script execution for the current PowerShell process.
Set-ExecutionPolicy Bypass -Scope Process -Force

# Ensures TLS 1.2 is included in the list of supported security protocols for web requests in the current PowerShell process.
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072

# Download and extract the Git repository without installing Git
try {
    $repoUrl = "https://github.com/TortoiseWolfe/AWS_min_WIN/archive/refs/heads/main.zip"
    $repoZipPath = "C:\AWS_min_WIN.zip"
    $repoExtractPath = "C:\AWS_min_WIN"

    (New-Object System.Net.WebClient).DownloadFile($repoUrl, $repoZipPath)

    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($repoZipPath, $repoExtractPath)

    # Move the contents of the extracted folder to the destination folder
    $extractedRepoFolder = Join-Path $repoExtractPath "AWS_min_WIN-main"
    Get-ChildItem -Path $extractedRepoFolder | Move-Item -Destination $destination

    # Remove the downloaded zip file and the extracted folder
    Remove-Item $repoZipPath
    Remove-Item $repoExtractPath -Recurse
} catch {
    Add-Content -Path $logFilePath -Value "Error downloading and extracting repository: $_"
}

# Run the example_script.ps1 file from the repo
$exampleScriptPath = Join-Path $destination "example_script.ps1"
if (Test-Path $exampleScriptPath) {
    try {
        & $exampleScriptPath
    } catch {
        Add-Content -Path $logFilePath -Value "Error running example_script.ps1: $_"
    }
} else {
    Add-Content -Path $logFilePath -Value "Error: example_script.ps1 not found in the repository"
}

Set-ExecutionPolicy RemoteSigned -Scope Process -Force
Add-Content -Path $logFilePath -Value "User Data executed."
</powershell>
