param(
    [string]$BindHost = "127.0.0.1",
    [int]$Port = 8787,
    [switch]$NoBrowser
)

$ErrorActionPreference = "Stop"

$repoWin = (Resolve-Path (Join-Path $PSScriptRoot "..\\..")).Path
$serverScript = Join-Path $repoWin "dashboard\\server.py"
if (-not (Test-Path $serverScript)) {
    throw "Dashboard server script not found: $serverScript"
}

if (-not (Get-Command python -ErrorAction SilentlyContinue)) {
    throw "python not found in PATH."
}

$url = "http://$BindHost`:$Port"
Write-Host "Starting dashboard server: $url"
Write-Host "Press Ctrl+C in this window to stop."

if (-not $NoBrowser) {
    Start-Process $url | Out-Null
}

& python $serverScript --host $BindHost --port $Port
exit $LASTEXITCODE
