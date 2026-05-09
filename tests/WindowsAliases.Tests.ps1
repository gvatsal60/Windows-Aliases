BeforeAll {
    $repoRoot = Split-Path -Parent $PSScriptRoot
    $aliasesPath = Join-Path -Path $repoRoot -ChildPath ".aliases.ps1"
    $installPath = Join-Path -Path $repoRoot -ChildPath "install.ps1"

    . $aliasesPath

    $env:WINDOWS_ALIASES_SKIP_MAIN = "1"
    . $installPath
    Remove-Item Env:WINDOWS_ALIASES_SKIP_MAIN
}

Describe "Windows aliases" {
    It "ll includes hidden files" {
        $tempDir = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([System.Guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $tempDir | Out-Null

        try {
            New-Item -ItemType File -Path (Join-Path -Path $tempDir -ChildPath "visible.txt") | Out-Null
            New-Item -ItemType File -Path (Join-Path -Path $tempDir -ChildPath ".hidden.txt") | Out-Null

            $items = ll $tempDir | Select-Object -ExpandProperty Name

            $items | Should -Contain "visible.txt"
            $items | Should -Contain ".hidden.txt"
        }
        finally {
            Remove-Item -LiteralPath $tempDir -Recurse -Force
        }
    }

    It "gts forwards to git status" {
        $tempDir = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([System.Guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $tempDir | Out-Null

        try {
            git -C $tempDir init --quiet --initial-branch=main
            Set-Content -LiteralPath (Join-Path -Path $tempDir -ChildPath "sample.txt") -Value "content"

            $status = gts -C $tempDir --short | Out-String

            $status | Should -Match "\?\? sample\.txt"
        }
        finally {
            Remove-Item -LiteralPath $tempDir -Recurse -Force
        }
    }
}

Describe "install.ps1" {
    It "downloads the aliases file to the configured location" {
        Set-Variable -Scope Script -Name FilePath -Value "/tmp/.aliases.ps1"
        Set-Variable -Scope Script -Name AliasSourceUrl -Value "https://example.invalid/.aliases.ps1"

        Mock Invoke-WebRequest {}

        Download-AliasFile

        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter {
            $Uri -eq "https://example.invalid/.aliases.ps1" -and $OutFile -eq "/tmp/.aliases.ps1"
        }
    }

    It "adds the profile source block only once" {
        $tempDir = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([System.Guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $tempDir | Out-Null

        try {
            $aliasPath = Join-Path -Path $tempDir -ChildPath ".aliases.ps1"
            $profilePath = Join-Path -Path $tempDir -ChildPath "profile.ps1"

            Set-Variable -Scope Script -Name FilePath -Value $aliasPath
            Set-Variable -Scope Script -Name ProfilePath -Value $profilePath
            Set-Variable -Scope Script -Name AliasSourceBlock -Value @"

# Common and useful aliases
if (Test-Path -LiteralPath "$aliasPath") {
    . "$aliasPath"
}
"@

            Update-Profile
            Update-Profile

            $profileContents = Get-Content -LiteralPath $profilePath -Raw

            ([regex]::Matches($profileContents, [regex]::Escape($aliasPath))).Count | Should -Be 1
        }
        finally {
            Remove-Item -LiteralPath $tempDir -Recurse -Force
        }
    }
}
