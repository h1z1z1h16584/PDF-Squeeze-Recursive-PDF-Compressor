# 1. Initialize Paths (Run from script's current directory)
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition
Set-Location $scriptPath

$sourceDir = $scriptPath
$outputDir = Join-Path $scriptPath "Output"
$totalOldSize = 0
$totalNewSize = 0

# Create Output folder if it does not exist
if (!(Test-Path $outputDir)) { New-Item -ItemType Directory -Force -Path $outputDir }

# Helper Function: Native Windows Desktop Notification
function Show-Notification ($title, $message, $icon = 'Info') {
    Add-Type -AssemblyName System.Windows.Forms
    $notify = New-Object System.Windows.Forms.NotifyIcon
    $notify.Icon = [System.Drawing.SystemIcons]::Information
    $notify.Visible = $true
    $notify.ShowBalloonTip(5000, $title, $message, $icon)
    Start-Sleep -Seconds 2
    $notify.Dispose()
}

# 2. Find Ghostscript
$gsExe = Get-Command "gswin64c.exe" -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source
if (-not $gsExe) {
    $searchPaths = @("C:\Program Files\gs", "C:\Program Files (x86)\gs", "$env:LOCALAPPDATA\gs")
    $gsExe = Get-ChildItem -Path $searchPaths -Filter "gswin64c.exe" -Recurse -ErrorAction SilentlyContinue | 
               Select-Object -ExpandProperty FullName -First 1
}

if (-not $gsExe) {
    Write-Host "ERROR: Ghostscript not found!" -ForegroundColor Red
    Show-Notification "PDF Compression Error" "Ghostscript (gswin64c.exe) was not found on this system." "Error"
    Pause; exit
}

# 3. Process Files Recursively (excluding the Output directory itself)
$pdfFiles = @(Get-ChildItem -Path $sourceDir -Filter *.pdf -Recurse | Where-Object { $_.FullName -notlike "$outputDir*" })

if ($pdfFiles.Count -eq 0) {
    Write-Host "No PDFs found in '$sourceDir'." -ForegroundColor Yellow
    Show-Notification "PDF Compression" "No PDF files found to compress." "Warning"
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

    # 4. Trigger Windows Desktop Notification
    Show-Notification "PDF Compression Complete" "Processed $($pdfFiles.Count) file(s).`nTotal Space Saved: $savedMB MB"
}
Pause
