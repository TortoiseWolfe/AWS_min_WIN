# Set destination folder and log file path
$destination = "C:\Program Files\AWS_min_WIN"
$logFilePath = Join-Path $destination "log.txt"

# Check if the destination folder exists, if not create it
if (!(Test-Path $destination)) {
    New-Item -ItemType Directory -Force -Path $destination
}

# Set the execution policy to bypass the current scope
Set-ExecutionPolicy Bypass -Scope Process -Force

# Set the security protocol to include TLS 1.2 
# [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor [System.Net.SecurityProtocolType]::Tls12

# Download and extract the Git repository without installing Git
try {
    $repoUrl = "https://github.com/TortoiseWolfe/AWS_min_WIN/archive/refs/heads/main.zip"
    $repoZipPath = "C:\AWS_min_WIN.zip"
    $repoExtractPath = "C:\AWS_min_WIN"

    # Download the zip file from the repository URL
    (New-Object System.Net.WebClient).DownloadFile($repoUrl, $repoZipPath)

    # Extract the contents of the zip file
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    [System.IO.Compression.ZipFile]::ExtractToDirectory($repoZipPath, $repoExtractPath)

    # Move the contents of the extracted folder to the destination folder
    $extractedRepoFolder = Join-Path $repoExtractPath "AWS_min_WIN-main"
    Get-ChildItem -Path $extractedRepoFolder | Move-Item -Destination $destination

    # Remove the downloaded zip file and the extracted folder
    Remove-Item $repoZipPath
    Remove-Item $repoExtractPath -Recurse
} catch {
    # Log any errors encountered while downloading and extracting the repository
    Add-Content -Path $logFilePath -Value "Error downloading and extracting repository: $_"
}

# Run the example_script.ps1 file from the repo
$exampleScriptPath = Join-Path $destination "example_script.ps1"
if (Test-Path $exampleScriptPath) {
    try {
        # Execute the example_script.ps1 file with the bypass execution policy
        Start-Process -FilePath "powershell.exe" -ArgumentList "-ExecutionPolicy Bypass -File `"$exampleScriptPath`"" -NoNewWindow
    } catch {
        # Log any errors encountered while running the example_script.ps1 file
        Add-Content -Path $logFilePath -Value "Error running example_script.ps1: $_"
    }
} else {
    # Log an error if the example_script.ps1 file is not found in the repository
    Add-Content -Path $logFilePath -Value "Error: example_script.ps1 not found in the repository"
}

# Reset the execution policy to RemoteSigned
Set-ExecutionPolicy RemoteSigned -Scope Process -Force