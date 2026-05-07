###################################################################################################
# File: .aliases.ps1
# Author: [Vatsal Gupta (gvatsal60)]
# Date: 07-May-2026
# Description: Common aliases and helper functions for Windows PowerShell.
###################################################################################################

###################################################################################################
# License
###################################################################################################
# This script is licensed under the Apache 2.0 License.

###################################################################################################
# Functions
###################################################################################################
function Get-GitBranch {
    $branch = git branch --show-current 2>$null
    if ([string]::IsNullOrWhiteSpace($branch)) {
        return ""
    }
    return "[$branch]"
}

function gsquash {
    param(
        [Parameter(Mandatory = $true)]
        [int]$Count
    )
    git rebase -i "HEAD~$Count"
}

###################################################################################################
# File Management
###################################################################################################
function l { Get-ChildItem @args }
function ll { Get-ChildItem -Force @args }
function la { Get-ChildItem -Force @args }
function lt { Get-ChildItem @args | Sort-Object Length -Descending }
function recent { Get-ChildItem @args | Sort-Object LastWriteTime -Descending | Select-Object -First 10 }
function count { (Get-ChildItem @args).Count }
Set-Alias -Name p -Value Get-Location

###################################################################################################
# Navigation
###################################################################################################
function .. { Set-Location .. }
function ... { Set-Location ../.. }

###################################################################################################
# System Information
###################################################################################################
Set-Alias -Name cl -Value Clear-Host
Set-Alias -Name h -Value Get-History
Set-Alias -Name j -Value Get-Job
function size {
    param([string]$Path = ".")
    (Get-Item -LiteralPath $Path).Length
}

###################################################################################################
# Miscellaneous
###################################################################################################
Set-Alias -Name q -Value Exit

###################################################################################################
# Git
###################################################################################################
function gts { git status @args }
function gtp { git pull @args }
function gtdf { git diff --ignore-space-change @args }
function gsupdate { git submodule update --init --recursive @args }
function gtc { git checkout @args }
function gtclean { git clean -fd @args }
function gcm { git commit @args }
function gd { git diff @args }
function gb { git branch @args }
function ga { git add @args }
function gl { git log @args }
function glpo { git log --pretty=oneline @args }
function gtcbd {
    git for-each-ref --format='%(refname:short)' refs/heads |
        Where-Object { $_ -ne "master" -and $_ -ne "main" } |
        ForEach-Object { git branch -d $_ }
}

###################################################################################################
# Docker
###################################################################################################
function dc { docker-compose @args }
function dce { docker-compose exec @args }
function dcr { docker-compose run --rm @args }
function dcb { docker-compose build @args }
function dclg { docker-compose logs @args }
function dcpf { docker-compose pause @args }
function dcunp { docker-compose unpause @args }
function dcps { docker-compose ps @args }
function dcup { docker-compose up @args }
function dcud { docker-compose up -d @args }
function dcstp { docker-compose stop @args }
function dcstart { docker-compose start @args }
function dcrmv { docker-compose rm -v @args }
function dps { docker ps -a @args }
function drm { docker container rm @args }
function dimg { docker image @args }
function drimg { docker image rm @args }
function dimgs { docker image ls @args }
function dvol { docker volume @args }
function dcl { docker system prune -f; docker builder prune -f }

###################################################################################################
# Terraform
###################################################################################################
function tf { terraform @args }
function tfi { terraform init @args }
function tfa { terraform apply @args }
function tfp { terraform plan @args }
function tfd { terraform destroy @args }
function tfws { terraform workspace @args }
function tfwsl { terraform workspace list @args }
function tfwsc { terraform workspace select @args }
