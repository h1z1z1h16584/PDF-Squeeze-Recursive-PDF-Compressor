# 1. Initialize Paths
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $scriptPath

$sourceDir = Join-Path $scriptPath "Input"
$outputDir = Join-Path $scriptPath "Output"
$totalOldSize = 0
$totalNewSize = 0

# Create folders
if (!(Test-Path $sourceDir)) { New-Item -ItemType Directory -Force -Path $sourceDir }
if (!(Test-Path $outputDir)) { New-Item -ItemType Directory -Force -Path $outputDir }

# 2. Find Ghostscript
$gsExe = Get-Command "gswin64c.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $gsExe) {
    $searchPaths = @("C:\Program Files\gs", "C:\Program Files (x86)\gs", "$env:LOCALAPPDATA\gs")
    $gsExe = Get-ChildItem -Path $searchPaths -Filter "gswin64c.exe" -Recurse -ErrorAction SilentlyContinue | 
              Select-Object -ExpandProperty FullName -First 1
}

if (-not $gsExe) {
    Write-Host "ERROR: Ghostscript not found!" -ForegroundColor Red
    Pause; exit
}

# 3. Process Files Recursively
$pdfFiles = Get-ChildItem -Path $sourceDir -Filter *.pdf -Recurse

if ($pdfFiles.Count -eq 0) {
    Write-Host "No PDFs found in '$sourceDir'." -ForegroundColor Yellow
} else {
    foreach ($file in $pdfFiles) {
        $relativePath = $file.FullName.Substring($sourceDir.Length + 1)
        $target = Join-Path $outputDir $relativePath
        $targetFolder = Split-Path -Parent $target

        if (!(Test-Path $targetFolder)) { New-Item -ItemType Directory -Force -Path $targetFolder }

        Write-Host "Processing: $relativePath..." -ForegroundColor White
        
        $gsArgs = @(
            "-sDEVICE=pdfwrite",
            "-dCompatibilityLevel=1.4",
            "-dPDFSETTINGS=/ebook",
            "-dNOPAUSE", "-dQUIET", "-dBATCH",
            "-sOutputFile=`"$target`"",
            "`"$($file.FullName)`""
        )

        & $gsExe @gsArgs

        if (Test-Path $target) {
            $oldSize = $file.Length
            $newSize = (Get-Item $target).Length

            if ($newSize -ge $oldSize -and $oldSize -gt 0) {
                Write-Host "SKIPPED: No improvement. Keeping original." -ForegroundColor Yellow
                Copy-Item -Path $file.FullName -Destination $target -Force
                $totalOldSize += $oldSize
                $totalNewSize += $oldSize
            } else {
                $reduction = [math]::Round((($oldSize - $newSize) / $oldSize) * 100, 1)
                Write-Host "SUCCESS: Reduced by $reduction% ($([math]::Round($newSize/1MB,2)) MB)" -ForegroundColor Green
                $totalOldSize += $oldSize
                $totalNewSize += $newSize
            }
        }
    }
    
    # Final Summary
    $savedMB = [math]::Round(($totalOldSize - $totalNewSize) / 1MB, 2)
    Write-Host "`n===============================================" -ForegroundColor Cyan
    Write-Host "TOTAL SPACE SAVED: $savedMB MB" -ForegroundColor Green
    Write-Host "===============================================" -ForegroundColor Cyan
}
Pause