Param(
  [string]$ApiBaseUrl = $null,
  [string[]]$FlutterArgs = @()
)

$root = Split-Path -Parent $PSScriptRoot
$envFile = Join-Path $root ".env"

if (-not (Test-Path $envFile)) {
  Write-Error "Missing .env at $envFile"
  exit 1
}

$envMap = @{}
Get-Content $envFile | ForEach-Object {
  $line = $_.Trim()
  if ($line.Length -eq 0) { return }
  if ($line.StartsWith("#")) { return }
  if ($line -notmatch "=") { return }
  $parts = $line -split "=", 2
  $key = $parts[0].Trim()
  $val = $parts[1].Trim()
  if ($val.StartsWith('"') -and $val.EndsWith('"')) {
    $val = $val.Substring(1, $val.Length - 2)
  }
  $envMap[$key] = $val
}

if ($ApiBaseUrl) { $envMap["API_BASE_URL"] = $ApiBaseUrl }

$defines = @()
if ($envMap.ContainsKey("API_BASE_URL")) {
  $defines += "--dart-define=API_BASE_URL=$($envMap["API_BASE_URL"])"
}

Set-Location (Join-Path $root "mobile")

$allArgs = @("run") + $defines + $FlutterArgs
Write-Host "flutter $($allArgs -join ' ')"
flutter @allArgs
