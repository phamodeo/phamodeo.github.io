# Regenerates resume.pdf from resume.html and stamps the "Updated" month.
# Run from anywhere after editing resume.html:
#   powershell -NoProfile -ExecutionPolicy Bypass -File tools/build-resume-pdf.ps1
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$html = Join-Path $root 'resume.html'
$pdf  = Join-Path $root 'resume.pdf'

# Stamp the current month (English, e.g. "Nov 2026") into the footer line.
$stamp = (Get-Date).ToString('MMM yyyy', [System.Globalization.CultureInfo]::InvariantCulture)
$text = [IO.File]::ReadAllText($html, [Text.Encoding]::UTF8)
$text = [regex]::Replace($text, '(<span id="updated">)[^<]*(</span>)', "`${1}$stamp`${2}")
[IO.File]::WriteAllText($html, $text, (New-Object Text.UTF8Encoding $false))

$browser = @(
  "$env:ProgramFiles\Google\Chrome\Application\chrome.exe",
  "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $browser) { throw 'Chrome or Edge not found.' }

if (Test-Path $pdf) { Remove-Item $pdf }
# Fresh profile so no extension or session of the real browser gets in the way;
# stderr goes to a file because the browser logs noise there even on success.
$profile = Join-Path $env:TEMP 'resume-pdf-profile'
$errLog  = Join-Path $env:TEMP 'resume-pdf.err'
$url = 'file:///' + $html.Replace('\', '/')
$argList = @('--headless=new', '--disable-gpu', '--no-first-run', "--user-data-dir=`"$profile`"",
             '--no-pdf-header-footer', "--print-to-pdf=`"$pdf`"", "`"$url`"")
Start-Process -FilePath $browser -ArgumentList $argList -Wait -NoNewWindow -RedirectStandardError $errLog
if (-not (Test-Path $pdf)) { throw "PDF was not written. See $errLog" }
"resume.pdf written ($((Get-Item $pdf).Length) bytes), stamped $stamp"
