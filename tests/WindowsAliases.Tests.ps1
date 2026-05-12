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
            Push-Location -LiteralPath $tempDir
            try {
                $status = gts --short | Out-String

                $status | Should -Match "\?\? sample\.txt"
            }
            finally {
                Pop-Location
            }
        }
        finally {
            Remove-Item -LiteralPath $tempDir -Recurse -Force
        }
    }
}

Describe "install.ps1" {
    It "downloads the aliases file to the configured location" {
        $destinationPath = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([System.Guid]::NewGuid().ToString())

        Mock Invoke-WebRequest {}

        Download-AliasFile -DestinationPath $destinationPath -SourceUrl "https://example.invalid/.aliases.ps1"

        Should -Invoke Invoke-WebRequest -Times 1 -Exactly -ParameterFilter {
            $Uri -eq "https://example.invalid/.aliases.ps1" -and $OutFile -eq $destinationPath
        }
    }

    It "adds the profile source block to a new empty profile only once" {
        $tempDir = Join-Path -Path ([System.IO.Path]::GetTempPath()) -ChildPath ([System.Guid]::NewGuid().ToString())
        New-Item -ItemType Directory -Path $tempDir | Out-Null

        try {
            $aliasPath = Join-Path -Path $tempDir -ChildPath ".aliases.ps1"
            $profilePath = Join-Path -Path $tempDir -ChildPath "profile.ps1"
            $profileSnippet = @"

# Common and useful aliases
if (Test-Path -LiteralPath "$aliasPath") {
    . "$aliasPath"
}
"@

            Update-Profile -ProfileFilePath $profilePath -AliasFilePath $aliasPath -ProfileSnippet $profileSnippet
            $firstProfileContents = Get-Content -LiteralPath $profilePath -Raw
            $snippetCountAfterFirstUpdate = ([regex]::Matches($firstProfileContents, [regex]::Escape($profileSnippet))).Count
            $snippetCountAfterFirstUpdate | Should -Be 1

            Update-Profile -ProfileFilePath $profilePath -AliasFilePath $aliasPath -ProfileSnippet $profileSnippet

            $secondProfileContents = Get-Content -LiteralPath $profilePath -Raw
            $snippetCountAfterSecondUpdate = ([regex]::Matches($secondProfileContents, [regex]::Escape($profileSnippet))).Count
            $snippetCountAfterSecondUpdate | Should -Be 1
        }
        finally {
            Remove-Item -LiteralPath $tempDir -Recurse -Force
        }
    }
}
