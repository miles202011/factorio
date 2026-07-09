param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$InputPath,

    [int]$Size = 0,

    [switch]$Overwrite
)

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$KnownFfmpeg = "D:\桌面\下载\ffmpeg-master-latest-win64-gpl-shared\ffmpeg-master-latest-win64-gpl-shared\bin\ffmpeg.exe"

function Get-FfmpegPath {
    if (Test-Path -LiteralPath $KnownFfmpeg) {
        return $KnownFfmpeg
    }

    $cmd = Get-Command ffmpeg -ErrorAction SilentlyContinue
    if ($cmd) {
        return $cmd.Source
    }

    throw "ffmpeg.exe not found. Put ffmpeg in PATH or edit `$KnownFfmpeg in this script."
}

function Get-OutputPath([string]$SourcePath) {
    $dir = Split-Path -Parent $SourcePath
    $base = [System.IO.Path]::GetFileNameWithoutExtension($SourcePath)
    $out = Join-Path $dir ($base + ".png")

    if ($Overwrite -or -not (Test-Path -LiteralPath $out)) {
        return $out
    }

    for ($i = 1; $i -lt 1000; $i++) {
        $candidate = Join-Path $dir ($base + "_" + $i + ".png")
        if (-not (Test-Path -LiteralPath $candidate)) {
            return $candidate
        }
    }

    throw "Too many output files already exist for $SourcePath"
}

function Get-InputFiles {
    if (-not $InputPath -or $InputPath.Count -eq 0) {
        return Get-ChildItem -LiteralPath $ScriptDir -File |
            Where-Object { $_.Extension.ToLowerInvariant() -in @(".webp", ".jpg", ".jpeg", ".bmp", ".gif", ".avif") }
    }

    $files = New-Object System.Collections.Generic.List[System.IO.FileInfo]
    foreach ($path in $InputPath) {
        if (-not (Test-Path -LiteralPath $path)) {
            Write-Warning "Not found: $path"
            continue
        }

        $item = Get-Item -LiteralPath $path
        if ($item.PSIsContainer) {
            Get-ChildItem -LiteralPath $item.FullName -File |
                Where-Object { $_.Extension.ToLowerInvariant() -in @(".webp", ".jpg", ".jpeg", ".bmp", ".gif", ".avif") } |
                ForEach-Object { $files.Add($_) }
        } else {
            $files.Add($item)
        }
    }
    return $files
}

$ffmpeg = Get-FfmpegPath
$files = @(Get-InputFiles)

if ($files.Count -eq 0) {
    Write-Host "No supported image files found."
    Write-Host "Supported: webp, jpg, jpeg, bmp, gif, avif"
    exit 0
}

foreach ($file in $files) {
    $out = Get-OutputPath $file.FullName
    Write-Host "Converting: $($file.Name) -> $(Split-Path -Leaf $out)"

    $args = @("-y", "-hide_banner", "-loglevel", "error", "-i", $file.FullName, "-frames:v", "1")

    if ($Size -gt 0) {
        $vf = "scale=${Size}:${Size}:force_original_aspect_ratio=decrease,pad=${Size}:${Size}:(ow-iw)/2:(oh-ih)/2:color=0x00000000"
        $args += @("-vf", $vf)
    }

    $args += $out
    & $ffmpeg @args

    if ($LASTEXITCODE -ne 0) {
        Write-Warning "Failed: $($file.FullName)"
    }
}

Write-Host "Done."
