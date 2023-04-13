<powershell>
# Install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Install Git using Chocolatey
choco install git -y

# Clone the repository
$repoUrl = "https://github.com/TortoiseWolfe/AWS_min_WIN.git"
$destination = "C:\AWS_min_WIN"
git clone $repoUrl $destination

# Reset Execution Policy
Set-ExecutionPolicy RemoteSigned -Scope Process -Force
</powershell>
