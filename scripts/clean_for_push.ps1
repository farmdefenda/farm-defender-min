# ============================================================================
# Clean Repository Before Push
# ============================================================================
# This script removes any files that shouldn't be in the repository
# and ensures a clean state before pushing to GitHub.
# ============================================================================

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Repository Cleanup Script" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Change to project root
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
Set-Location $projectRoot
Write-Host "Working in: $projectRoot" -ForegroundColor Gray

# Files to remove from git tracking (but keep locally)
$filesToUntrack = @(
    "android/local.properties",
    "scripts/upload-keystore.jks",
    "scripts/keystore_base64.txt",
    "android/key.properties",
    ".flutter-plugins",
    ".flutter-plugins-dependencies"
)

Write-Host ""
Write-Host "Removing files from git tracking..." -ForegroundColor Yellow

foreach ($file in $filesToUntrack) {
    $fullPath = Join-Path $projectRoot $file
    if (Test-Path $fullPath) {
        Write-Host "  Untracking: $file" -ForegroundColor Gray
        git rm --cached $file 2>$null
    }
}

# Remove entire directories from tracking
$dirsToUntrack = @(
    ".dart_tool",
    "build",
    ".idea",
    ".vscode",
    ".cursor",
    "android/.gradle",
    "android/app/build",
    "ios/Pods",
    "ios/.symlinks"
)

Write-Host ""
Write-Host "Removing directories from git tracking..." -ForegroundColor Yellow

foreach ($dir in $dirsToUntrack) {
    $fullPath = Join-Path $projectRoot $dir
    if (Test-Path $fullPath) {
        Write-Host "  Untracking: $dir" -ForegroundColor Gray
        git rm -r --cached $dir 2>$null
    }
}

# Clean Flutter project
Write-Host ""
Write-Host "Cleaning Flutter project..." -ForegroundColor Yellow
flutter clean 2>$null

# Regenerate necessary files
Write-Host ""
Write-Host "Regenerating dependencies..." -ForegroundColor Yellow
flutter pub get 2>$null

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  Cleanup Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Review changes: git status" -ForegroundColor Gray
Write-Host "  2. Add all files: git add ." -ForegroundColor Gray
Write-Host "  3. Commit: git commit -m 'Clean repository for handoff'" -ForegroundColor Gray
Write-Host "  4. Push: git push origin main" -ForegroundColor Gray
Write-Host ""

# Show what will be committed
Write-Host "Files staged for commit:" -ForegroundColor Cyan
git status --short
Write-Host ""

