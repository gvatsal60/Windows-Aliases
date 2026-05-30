###################################################################################################
# File: install.ps1
# Author: [Vatsal Gupta (gvatsal60)]
# Date: 07-May-2026
# Description: Installs Windows aliases by downloading .aliases.ps1 and wiring it to $PROFILE.
###################################################################################################

###################################################################################################
# License
###################################################################################################
# This script is licensed under the Apache 2.0 License.

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

###################################################################################################
# Global Variables & Constants
###################################################################################################
$FileName = ".aliases.ps1"
$FilePath = Join-Path -Path $HOME -ChildPath $FileName
$AliasSourceUrl = "https://raw.githubusercontent.com/gvatsal60/Windows-Aliases/HEAD/$FileName"
$ProfilePath = $PROFILE.CurrentUserAllHosts

$AliasSourceBlock = @"

# Common and useful aliases
if (Test-Path -LiteralPath "$FilePath") {
    . "$FilePath"
}
"@

###################################################################################################
# Functions
###################################################################################################
function Write-Info {
    param([string]$Message)
    Write-Host $Message
}

function Write-ErrorAndExit {
    param([string]$Message)
    Write-Error $Message
    exit 1
}

function Download-AliasFile {
    param(
        [string]$DestinationPath = $FilePath,
        [string]$SourceUrl = $AliasSourceUrl
    )

    Write-Info "=> Downloading aliases to: $DestinationPath"
    Invoke-WebRequest -Uri $SourceUrl -OutFile $DestinationPath
}

function Update-Profile {
    param(
        [string]$ProfileFilePath = $ProfilePath,
        [string]$AliasFilePath = $FilePath,
        [string]$ProfileSnippet = $AliasSourceBlock
    )

    $profileDir = Split-Path -Parent $ProfileFilePath
    if (-not (Test-Path -LiteralPath $profileDir)) {
        New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
    }

    if (-not (Test-Path -LiteralPath $ProfileFilePath)) {
        New-Item -ItemType File -Path $ProfileFilePath -Force | Out-Null
    }

    $profileContents = Get-Content -LiteralPath $ProfileFilePath -Raw
    if ($null -eq $profileContents) {
        $profileContents = ""
    }
    if ($profileContents -notmatch [Regex]::Escape($AliasFilePath)) {
        Write-Info "=> Updating profile: $ProfileFilePath"
        Add-Content -LiteralPath $ProfileFilePath -Value $ProfileSnippet
    }

    Write-Info ""
    Write-Info "=> Close and reopen your terminal to start using aliases"
    Write-Info "   OR"
    Write-Info "=> Run the following to use it now:"
    Write-Info ">>> . $ProfileFilePath"
}

###################################################################################################
# Main Script
###################################################################################################
function Invoke-Installer {
    if ([System.Environment]::OSVersion.Platform -ne [System.PlatformID]::Win32NT) {
        Write-ErrorAndExit "Error: This installer is intended for Windows PowerShell."
    }

    $action = "y"
    if ($Host.UI.RawUI -and (Test-Path -LiteralPath $FilePath)) {
        $response = Read-Host "=> File already exists: $FilePath`n=> Replace it? [y/n] (default: y)"
        if (-not [string]::IsNullOrWhiteSpace($response)) {
            $action = $response.ToLowerInvariant()
        }
    }

    if ($action -eq "y") {
        Download-AliasFile
        Update-Profile
    }
    elseif ($action -eq "n") {
        Write-Info "=> Keeping existing file: $FilePath"
    }
    else {
        Write-ErrorAndExit "Error: Invalid input. Please use y or n."
    }
}

if (-not $env:WINDOWS_ALIASES_SKIP_MAIN) {
    Invoke-Installer
}
