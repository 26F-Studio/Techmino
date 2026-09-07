[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $X86Zip,

    [Parameter(Mandatory = $true)]
    [string] $X64Zip,

    [Parameter(Mandatory = $true)]
    [string] $OutputExe,

    [Parameter(Mandatory = $true)]
    [string] $Template,

    [Parameter(Mandatory = $true)]
    [string] $IconPath,

    [Parameter(Mandatory = $true)]
    [string] $VersionString,

    [string] $ProductName = "Techmino",
    [string] $AppExe = "Techmino.exe",
    [string] $MakeNsisPath = "makensis.exe"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

function Resolve-FullPath([string] $Path) {
    if (Test-Path -LiteralPath $Path) {
        return (Resolve-Path -LiteralPath $Path).Path
    }
    return [System.IO.Path]::GetFullPath($Path)
}

function Normalize-FileVersion([string] $Version) {
    $parts = @()
    foreach ($piece in ($Version -split '\.')) {
        $match = [regex]::Match($piece, '^\d+')
        if ($match.Success) {
            $parts += [int] $match.Value
        }
        else {
            $parts += 0
        }
    }

    while ($parts.Count -lt 4) {
        $parts += 0
    }
    if ($parts.Count -gt 4) {
        $parts = $parts[0..3]
    }

    return ($parts -join '.')
}

$x86ZipFull = Resolve-FullPath $X86Zip
$x64ZipFull = Resolve-FullPath $X64Zip
$templateFull = Resolve-FullPath $Template
$iconFull = Resolve-FullPath $IconPath
$outputFull = Resolve-FullPath $OutputExe
$outputDir = Split-Path -Parent $outputFull

foreach ($required in @($x86ZipFull, $x64ZipFull, $templateFull, $iconFull)) {
    if (-not (Test-Path -LiteralPath $required -PathType Leaf)) {
        throw "Required input file not found: $required"
    }
}

if (-not (Test-Path -LiteralPath $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
}

$workRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("techmino-single-exe-" + [guid]::NewGuid().ToString("N"))
$x86Dir = Join-Path $workRoot "x86"
$x64Dir = Join-Path $workRoot "x64"

try {
    New-Item -ItemType Directory -Path $x86Dir -Force | Out-Null
    New-Item -ItemType Directory -Path $x64Dir -Force | Out-Null

    Expand-Archive -LiteralPath $x86ZipFull -DestinationPath $x86Dir -Force
    Expand-Archive -LiteralPath $x64ZipFull -DestinationPath $x64Dir -Force

    $x86App = Join-Path $x86Dir $AppExe
    $x64App = Join-Path $x64Dir $AppExe
    if (-not (Test-Path -LiteralPath $x86App -PathType Leaf)) {
        throw "$AppExe was not found at the root of the x86 package: $x86ZipFull"
    }
    if (-not (Test-Path -LiteralPath $x64App -PathType Leaf)) {
        throw "$AppExe was not found at the root of the x64 package: $x64ZipFull"
    }

    $licenseX86 = Join-Path $x86Dir "license.txt"
    $licenseX64 = Join-Path $x64Dir "license.txt"
    if (-not (Test-Path -LiteralPath $licenseX86 -PathType Leaf) -or
        -not (Test-Path -LiteralPath $licenseX64 -PathType Leaf)) {
        throw "license.txt must remain in both Windows payloads before creating the single-file executable."
    }

    $fileVersion = Normalize-FileVersion $VersionString

    $makensisCommand = Get-Command $MakeNsisPath -ErrorAction SilentlyContinue
    $makensisResolved = if ($null -ne $makensisCommand) { $makensisCommand.Source } else { $null }

    if ($null -eq $makensisResolved) {
        $candidates = @()
        if ($env:ProgramFiles) {
            $candidates += Join-Path $env:ProgramFiles "NSIS\makensis.exe"
        }
        if (${env:ProgramFiles(x86)}) {
            $candidates += Join-Path ${env:ProgramFiles(x86)} "NSIS\makensis.exe"
        }
        $candidates = @($candidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf })

        if ($candidates.Count -gt 0) {
            $makensisResolved = $candidates[0]
        }
    }

    if ($null -eq $makensisResolved) {
        throw "makensis.exe was not found. Install NSIS before running this script."
    }

    $defineArgs = @(
        "/DPRODUCT_NAME=$ProductName",
        "/DAPP_EXE=$AppExe",
        "/DOUTPUT_EXE=$outputFull",
        "/DPAYLOAD_X86=$x86Dir",
        "/DPAYLOAD_X64=$x64Dir",
        "/DICON_PATH=$iconFull",
        "/DVERSION_STRING=$VersionString",
        "/DFILE_VERSION=$fileVersion",
        $templateFull
    )

    & $makensisResolved @defineArgs
    if ($LASTEXITCODE -ne 0) {
        throw "makensis.exe failed with exit code $LASTEXITCODE"
    }

    if (-not (Test-Path -LiteralPath $outputFull -PathType Leaf)) {
        throw "NSIS completed without creating the expected output: $outputFull"
    }

    $size = (Get-Item -LiteralPath $outputFull).Length
    if ($size -le 0) {
        throw "The generated executable is empty: $outputFull"
    }

    Write-Host "Created universal Windows single-file package: $outputFull"
    Write-Host "Embedded x86 package: $x86ZipFull"
    Write-Host "Embedded x64 package: $x64ZipFull"
    Write-Host "File version: $fileVersion"
}
finally {
    if (Test-Path -LiteralPath $workRoot) {
        Remove-Item -LiteralPath $workRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
