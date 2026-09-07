[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $SingleExe,

    [Parameter(Mandatory = $true)]
    [string] $ExpectedX86Zip,

    [Parameter(Mandatory = $true)]
    [string] $ExpectedX64Zip,

    [string] $AppExe = "Techmino.exe"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$singleExeFull = (Resolve-Path -LiteralPath $SingleExe).Path
$expectedX86ZipFull = (Resolve-Path -LiteralPath $ExpectedX86Zip).Path
$expectedX64ZipFull = (Resolve-Path -LiteralPath $ExpectedX64Zip).Path
$verifyRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("techmino-single-exe-verify-" + [guid]::NewGuid().ToString("N"))

function Get-RelativeHashMap([string] $Root) {
    $rootFull = [System.IO.Path]::GetFullPath($Root).TrimEnd('\')
    $map = @{}
    Get-ChildItem -LiteralPath $rootFull -File -Recurse | ForEach-Object {
        $relative = $_.FullName.Substring($rootFull.Length).TrimStart('\')
        $map[$relative] = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash
    }
    return $map
}

function Assert-PayloadMatches([string] $Architecture, [string] $ExpectedZip) {
    $caseRoot = Join-Path $verifyRoot $Architecture
    $expectedDir = Join-Path $caseRoot "expected"
    $actualDir = Join-Path $caseRoot "actual"

    New-Item -ItemType Directory -Path $expectedDir -Force | Out-Null
    New-Item -ItemType Directory -Path $actualDir -Force | Out-Null
    Expand-Archive -LiteralPath $ExpectedZip -DestinationPath $expectedDir -Force

    $arguments = @(
        "/EXTRACT=$actualDir",
        "/ARCH=$Architecture"
    )
    $process = Start-Process -FilePath $singleExeFull -ArgumentList $arguments -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        throw "Single-file $Architecture extraction test failed with exit code $($process.ExitCode)."
    }

    if (-not (Test-Path -LiteralPath (Join-Path $actualDir $AppExe) -PathType Leaf)) {
        throw "$AppExe was not extracted from the $Architecture payload."
    }

    $expected = Get-RelativeHashMap $expectedDir
    $actual = Get-RelativeHashMap $actualDir

    $missing = @($expected.Keys | Where-Object { -not $actual.ContainsKey($_) })
    $extra = @($actual.Keys | Where-Object { -not $expected.ContainsKey($_) })
    $changed = @($expected.Keys | Where-Object { $actual.ContainsKey($_) -and $expected[$_] -ne $actual[$_] })

    if ($missing.Count -or $extra.Count -or $changed.Count) {
        $details = @()
        if ($missing.Count) { $details += "Missing: $($missing -join ', ')" }
        if ($extra.Count) { $details += "Extra: $($extra -join ', ')" }
        if ($changed.Count) { $details += "Hash mismatch: $($changed -join ', ')" }
        throw "Single-file $Architecture payload verification failed. $($details -join ' | ')"
    }

    Write-Host "Verified $Architecture payload: $($expected.Count) files, byte-for-byte."
}

try {
    New-Item -ItemType Directory -Path $verifyRoot -Force | Out-Null
    Assert-PayloadMatches -Architecture "x86" -ExpectedZip $expectedX86ZipFull
    Assert-PayloadMatches -Architecture "x64" -ExpectedZip $expectedX64ZipFull
    Write-Host "Verified universal Windows executable against both source packages."
}
finally {
    if (Test-Path -LiteralPath $verifyRoot) {
        Remove-Item -LiteralPath $verifyRoot -Recurse -Force -ErrorAction SilentlyContinue
    }
}
