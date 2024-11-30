# PowerShell script to install WSLTools Module

param (
    [string]$ModuleDirectory = "$HOME\PowerShell\Modules\WSLTools",
    [string]$GitHubUrl = "https://raw.githubusercontent.com/Copystrike/WSL-Forward/refs/heads/master/WSLTools.psm1"
)

Write-Output "Starting WSLTools module installation..."

# Create the module directory
if (-Not (Test-Path $ModuleDirectory)) {
    Write-Output "Creating module directory at $ModuleDirectory..."
    New-Item -ItemType Directory -Path $ModuleDirectory -Force -Verbose
}

# Download the WSLTools.psm1 file
$DestinationPath = Join-Path $ModuleDirectory "WSLTools.psm1"
Write-Output "Downloading module file from $GitHubUrl..."
Invoke-WebRequest -Uri $GitHubUrl -OutFile $DestinationPath -UseBasicParsing

# Verify download
if (Test-Path $DestinationPath) {
    Write-Output "Module file downloaded successfully to $DestinationPath."
} else {
    Write-Error "Failed to download the module file."
    exit 1
}

# Import the module
Write-Output "Importing the module..."
Import-Module $DestinationPath -Force

# Verify module installation
if (Get-Module -Name WSLTools -ListAvailable) {
    Write-Output "Module imported successfully. Adding to profile..."
    
    # Add to PowerShell profile
    $ProfilePath = $PROFILE
    if (-Not (Test-Path $ProfilePath)) {
        Write-Output "Creating PowerShell profile at $ProfilePath..."
        New-Item -ItemType File -Path $ProfilePath -Force -Verbose
    }

    $ImportCommand = "if (Test-Path '$DestinationPath') { Import-Module '$DestinationPath' }"
    if (-Not (Get-Content $ProfilePath | Select-String -Pattern $ImportCommand)) {
        Add-Content -Path $ProfilePath -Value $ImportCommand
        Write-Output "Added module import command to PowerShell profile."
    } else {
        Write-Output "Module import command already exists in PowerShell profile."
    }

    Write-Output "WSLTools module installed successfully."
} else {
    Write-Error "Failed to import the module."
    exit 1
}
