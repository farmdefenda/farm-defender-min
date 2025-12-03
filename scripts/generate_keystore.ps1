# ============================================================================
# Generate Android Upload Keystore for Play Store
# ============================================================================
# This script generates an upload keystore and outputs its Base64 encoding
# for use in GitHub Secrets.
#
# Usage: .\generate_keystore.ps1
# ============================================================================

param(
    [string]$KeystoreName = "upload-keystore.jks",
    [string]$KeyAlias = "upload",
    [int]$ValidityDays = 10000
)

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Android Keystore Generator" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if keytool is available
$keytoolPath = $null
$possiblePaths = @(
    "keytool",
    "$env:JAVA_HOME\bin\keytool.exe",
    "$env:ANDROID_HOME\jdk\*\bin\keytool.exe",
    "C:\Program Files\Android\Android Studio\jbr\bin\keytool.exe",
    "C:\Program Files\Java\*\bin\keytool.exe"
)

foreach ($path in $possiblePaths) {
    $resolved = Get-Command $path -ErrorAction SilentlyContinue
    if ($resolved) {
        $keytoolPath = $resolved.Source
        break
    }
    # Try glob patterns
    $globbed = Resolve-Path $path -ErrorAction SilentlyContinue
    if ($globbed) {
        $keytoolPath = $globbed.Path | Select-Object -First 1
        break
    }
}

if (-not $keytoolPath) {
    Write-Host "ERROR: keytool not found!" -ForegroundColor Red
    Write-Host "Please ensure Java JDK is installed and JAVA_HOME is set." -ForegroundColor Yellow
    exit 1
}

Write-Host "Using keytool: $keytoolPath" -ForegroundColor Gray
Write-Host ""

# Output directory
$outputDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$keystorePath = Join-Path $outputDir $KeystoreName

# Check if keystore already exists
if (Test-Path $keystorePath) {
    Write-Host "WARNING: Keystore already exists at: $keystorePath" -ForegroundColor Yellow
    $response = Read-Host "Do you want to overwrite it? (y/N)"
    if ($response -ne "y" -and $response -ne "Y") {
        Write-Host "Aborted." -ForegroundColor Red
        exit 1
    }
    Remove-Item $keystorePath -Force
}

Write-Host "Enter keystore details:" -ForegroundColor Yellow
Write-Host ""

# Collect user input
$storePassword = Read-Host "Enter keystore password (min 6 characters)" -AsSecureString
$storePasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($storePassword))

$keyPassword = Read-Host "Enter key password (min 6 characters, press Enter for same as keystore)" -AsSecureString
$keyPasswordPlain = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPassword))

if ([string]::IsNullOrEmpty($keyPasswordPlain)) {
    $keyPasswordPlain = $storePasswordPlain
}

Write-Host ""
Write-Host "Enter certificate details (press Enter for defaults):" -ForegroundColor Yellow

$cn = Read-Host "Your name [Farm Defender Developer]"
if ([string]::IsNullOrEmpty($cn)) { $cn = "Farm Defender Developer" }

$ou = Read-Host "Organizational unit [Development]"
if ([string]::IsNullOrEmpty($ou)) { $ou = "Development" }

$o = Read-Host "Organization [Farm Defender]"
if ([string]::IsNullOrEmpty($o)) { $o = "Farm Defender" }

$l = Read-Host "City [Unknown]"
if ([string]::IsNullOrEmpty($l)) { $l = "Unknown" }

$st = Read-Host "State [Unknown]"
if ([string]::IsNullOrEmpty($st)) { $st = "Unknown" }

$c = Read-Host "Country code (2 letters) [US]"
if ([string]::IsNullOrEmpty($c)) { $c = "US" }

$dname = "CN=$cn, OU=$ou, O=$o, L=$l, ST=$st, C=$c"

Write-Host ""
Write-Host "Generating keystore..." -ForegroundColor Cyan

# Generate keystore
$keytoolArgs = @(
    "-genkeypair",
    "-v",
    "-keystore", $keystorePath,
    "-alias", $KeyAlias,
    "-keyalg", "RSA",
    "-keysize", "2048",
    "-validity", $ValidityDays,
    "-storepass", $storePasswordPlain,
    "-keypass", $keyPasswordPlain,
    "-dname", $dname
)

& $keytoolPath @keytoolArgs

if ($LASTEXITCODE -ne 0) {
    Write-Host "ERROR: Failed to generate keystore!" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Keystore generated successfully!" -ForegroundColor Green
Write-Host "Location: $keystorePath" -ForegroundColor Gray
Write-Host ""

# Generate Base64
Write-Host "Generating Base64 encoding..." -ForegroundColor Cyan
$keystoreBytes = [System.IO.File]::ReadAllBytes($keystorePath)
$base64String = [System.Convert]::ToBase64String($keystoreBytes)

# Save Base64 to file
$base64FilePath = Join-Path $outputDir "keystore_base64.txt"
$base64String | Out-File -FilePath $base64FilePath -NoNewline -Encoding ASCII

Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  KEYSTORE GENERATED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Files created:" -ForegroundColor Yellow
Write-Host "  - $keystorePath" -ForegroundColor Gray
Write-Host "  - $base64FilePath" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  GitHub Secrets to Configure:" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. KEYSTORE_BASE64:" -ForegroundColor Yellow
Write-Host "   Copy contents from: $base64FilePath" -ForegroundColor Gray
Write-Host ""
Write-Host "2. KEY_ALIAS:" -ForegroundColor Yellow
Write-Host "   $KeyAlias" -ForegroundColor White
Write-Host ""
Write-Host "3. KEY_PASSWORD:" -ForegroundColor Yellow
Write-Host "   (The key password you entered)" -ForegroundColor Gray
Write-Host ""
Write-Host "4. KEYSTORE_PASSWORD:" -ForegroundColor Yellow
Write-Host "   (The keystore password you entered)" -ForegroundColor Gray
Write-Host ""
Write-Host "========================================" -ForegroundColor Red
Write-Host "  IMPORTANT SECURITY NOTES:" -ForegroundColor Red
Write-Host "========================================" -ForegroundColor Red
Write-Host ""
Write-Host "- Keep the .jks file SAFE and BACKED UP!" -ForegroundColor Yellow
Write-Host "- NEVER commit the keystore or passwords to git!" -ForegroundColor Yellow
Write-Host "- Delete keystore_base64.txt after copying to GitHub!" -ForegroundColor Yellow
Write-Host "- If you lose this keystore, you cannot update your app!" -ForegroundColor Yellow
Write-Host ""

# Copy Base64 to clipboard if possible
try {
    $base64String | Set-Clipboard
    Write-Host "Base64 string copied to clipboard!" -ForegroundColor Green
} catch {
    Write-Host "Could not copy to clipboard. Please copy manually from the file." -ForegroundColor Yellow
}

Write-Host ""

