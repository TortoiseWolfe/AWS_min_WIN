$psVersion = $PSVersionTable.PSVersion
"PowerShell version: $($psVersion.Major).$($psVersion.Minor)"

# Install the PSWindowsUpdate module if it's not already installed
if (-not (Get-Module -ListAvailable -Name PSWindowsUpdate)) {
    Install-Module -Name PSWindowsUpdate -Force
}

# Import the PSWindowsUpdate module
Import-Module PSWindowsUpdate

# Run Windows Update
Get-WindowsUpdate -Install -AcceptAll -Verbose
