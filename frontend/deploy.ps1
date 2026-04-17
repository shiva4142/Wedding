# Build the Flutter Web app pointing at your live API + site URL,
# then deploy to Firebase Hosting.
#
# Usage (from d:\wedding\frontend):
#   .\deploy.ps1 -ApiBase "https://wedding-api.onrender.com" -SiteUrl "https://your-site.web.app"

param(
  [Parameter(Mandatory = $true)] [string] $ApiBase,
  [Parameter(Mandatory = $true)] [string] $SiteUrl
)

Write-Host "Building Flutter Web with API_BASE=$ApiBase  SITE_URL=$SiteUrl" -ForegroundColor Cyan
flutter build web --release `
  --dart-define=API_BASE=$ApiBase `
  --dart-define=SITE_URL=$SiteUrl
if ($LASTEXITCODE -ne 0) { Write-Error "flutter build failed"; exit 1 }

Write-Host "Deploying to Firebase Hosting..." -ForegroundColor Cyan
firebase deploy --only hosting
if ($LASTEXITCODE -ne 0) { Write-Error "firebase deploy failed"; exit 1 }

Write-Host "Done. Open: $SiteUrl" -ForegroundColor Green
