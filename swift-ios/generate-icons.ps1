# Generate placeholder PNGs for AppIcon.appiconset
$files = @(
  'icon-20@2x.png', 'icon-20@3x.png',
  'icon-29@2x.png', 'icon-29@3x.png',
  'icon-40@2x.png', 'icon-40@3x.png',
  'icon-60@2x.png', 'icon-60@3x.png'
)

# 1x1 transparent PNG (base64)
$b64 = "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR4nGNgYAAAAAMAASsJTYQAAAAASUVORK5CYII="
$bytes = [System.Convert]::FromBase64String($b64)

$outDir = Join-Path -Path (Get-Location) -ChildPath 'Assets.xcassets\AppIcon.appiconset'
if (-not (Test-Path $outDir)) { New-Item -ItemType Directory -Path $outDir | Out-Null }

foreach ($f in $files) {
  $path = Join-Path $outDir $f
  [System.IO.File]::WriteAllBytes($path, $bytes)
  Write-Host "Wrote $path"
}

Write-Host "Placeholder icons created in Assets.xcassets/AppIcon.appiconset"
