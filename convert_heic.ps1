# Converts all HEIC images in this script's folder to PNG.
# Uses Windows' built-in imaging codecs (WPF/WIC) - the same decoders
# Photos/Explorer use. No Python, no pip installs needed.
#
# NOTE: This relies on Windows having HEIF decoding support installed.
# On most Windows 10/11 PCs this is already present. If it's missing,
# install the free "HEIF Image Extensions" from the Microsoft Store,
# then run this again.

Add-Type -AssemblyName PresentationCore

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "Looking for HEIC images in: $scriptDir"

$heicFiles = Get-ChildItem -Path $scriptDir -File | Where-Object {
    $_.Extension -match '^\.(heic|heif)$'
}

if ($heicFiles.Count -eq 0) {
    Write-Host "No HEIC files found in this folder."
    exit
}

Write-Host "Found $($heicFiles.Count) HEIC file(s). Converting..."
$converted = 0
$failed = 0

foreach ($file in $heicFiles) {
    $pngPath = Join-Path $scriptDir ([System.IO.Path]::GetFileNameWithoutExtension($file.Name) + ".png")

    if (Test-Path $pngPath) {
        Write-Host "  Skipping $($file.Name) -> already has a PNG"
        continue
    }

    try {
        $stream = New-Object System.IO.FileStream($file.FullName, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read)
        $decoder = New-Object System.Windows.Media.Imaging.BitmapImage
        $decoder.BeginInit()
        $decoder.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        $decoder.StreamSource = $stream
        $decoder.EndInit()
        $stream.Close()

        $encoder = New-Object System.Windows.Media.Imaging.PngBitmapEncoder
        $encoder.Frames.Add([System.Windows.Media.Imaging.BitmapFrame]::Create($decoder))

        $outStream = New-Object System.IO.FileStream($pngPath, [System.IO.FileMode]::Create)
        $encoder.Save($outStream)
        $outStream.Close()

        Write-Host "  Converted: $($file.Name) -> $(Split-Path $pngPath -Leaf)"
        $converted++
    }
    catch {
        Write-Host "  Failed: $($file.Name) - $($_.Exception.Message)"
        $failed++
    }
}

Write-Host ""
Write-Host "Done. $converted converted, $failed failed."

if ($failed -gt 0) {
    Write-Host ""
    Write-Host "If conversions failed, Windows may be missing HEIF support."
    Write-Host "Install the free 'HEIF Image Extensions' from the Microsoft Store, then try again."
}
