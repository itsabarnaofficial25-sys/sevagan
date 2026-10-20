# Phase 1 Verification Script

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Sevagan Phase 1 Verification" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

$allPassed = $true

# Check Docker containers
Write-Host "[1/8] Checking Docker containers..." -ForegroundColor Yellow
$containers = docker ps --format "{{.Names}}" 2>$null
$requiredContainers = @("sevagan-postgres", "sevagan-redis", "sevagan-backend", "sevagan-admin")

foreach ($container in $requiredContainers) {
    if ($containers -contains $container) {
        Write-Host "  ✓ $container is running" -ForegroundColor Green
    } else {
        Write-Host "  ✗ $container is NOT running" -ForegroundColor Red
        $allPassed = $false
    }
}

# Check database tables
Write-Host "`n[2/8] Checking database tables..." -ForegroundColor Yellow
$tableCount = docker exec sevagan-postgres psql -U sevagan_user -d sevagan -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE';" 2>$null
if ($tableCount -match "9") {
    Write-Host "  ✓ All 9 tables exist" -ForegroundColor Green
} else {
    Write-Host "  ✗ Expected 9 tables, found: $tableCount" -ForegroundColor Red
    $allPassed = $false
}

# Check service categories
Write-Host "`n[3/8] Checking service categories..." -ForegroundColor Yellow
$categoryCount = docker exec sevagan-postgres psql -U sevagan_user -d sevagan -t -c "SELECT COUNT(*) FROM service_categories;" 2>$null
if ($categoryCount -match "\d+" -and [int]$categoryCount.Trim() -ge 4) {
    Write-Host "  ✓ Service categories seeded ($($categoryCount.Trim()) categories)" -ForegroundColor Green
} else {
    Write-Host "  ✗ Service categories not seeded" -ForegroundColor Red
    $allPassed = $false
}

# Check admin user
Write-Host "`n[4/8] Checking admin user..." -ForegroundColor Yellow
$adminExists = docker exec sevagan-postgres psql -U sevagan_user -d sevagan -t -c "SELECT COUNT(*) FROM users WHERE role='ADMIN';" 2>$null
if ($adminExists -match "1") {
    Write-Host "  ✓ Admin user exists" -ForegroundColor Green
} else {
    Write-Host "  ✗ Admin user not found" -ForegroundColor Red
    $allPassed = $false
}

# Check backend .env
Write-Host "`n[5/8] Checking backend environment..." -ForegroundColor Yellow
if (Test-Path "backend\.env") {
    Write-Host "  ✓ backend/.env exists" -ForegroundColor Green
} else {
    Write-Host "  ✗ backend/.env missing" -ForegroundColor Red
    $allPassed = $false
}

# Check customer app .env
Write-Host "`n[6/8] Checking customer app environment..." -ForegroundColor Yellow
if (Test-Path "customer_app\.env") {
    $envContent = Get-Content "customer_app\.env" -Raw
    if ($envContent -match "API_BASE_URL") {
        Write-Host "  ✓ customer_app/.env exists with API_BASE_URL" -ForegroundColor Green
    } else {
        Write-Host "  ✗ customer_app/.env missing API_BASE_URL" -ForegroundColor Red
        $allPassed = $false
    }
} else {
    Write-Host "  ✗ customer_app/.env missing" -ForegroundColor Red
    $allPassed = $false
}

# Check technician app .env
Write-Host "`n[7/8] Checking technician app environment..." -ForegroundColor Yellow
if (Test-Path "technician_app\.env") {
    $envContent = Get-Content "technician_app\.env" -Raw
    if ($envContent -match "API_BASE_URL") {
        Write-Host "  ✓ technician_app/.env exists with API_BASE_URL" -ForegroundColor Green
    } else {
        Write-Host "  ✗ technician_app/.env missing API_BASE_URL" -ForegroundColor Red
        $allPassed = $false
    }
} else {
    Write-Host "  ✗ technician_app/.env missing" -ForegroundColor Red
    $allPassed = $false
}

# Check backend API
Write-Host "`n[8/8] Checking backend API..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api" -UseBasicParsing -TimeoutSec 5 2>$null
    if ($response.StatusCode -eq 200) {
        Write-Host "  ✓ Backend API is responding" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Backend API returned status: $($response.StatusCode)" -ForegroundColor Red
        $allPassed = $false
    }
} catch {
    Write-Host "  ✗ Backend API is not accessible" -ForegroundColor Red
    $allPassed = $false
}

# Summary
Write-Host "`n==================================" -ForegroundColor Cyan
if ($allPassed) {
    Write-Host "✓ Phase 1 Setup Complete!" -ForegroundColor Green
    Write-Host "`nYou can now:" -ForegroundColor White
    Write-Host "  • Test OTP login in mobile apps" -ForegroundColor White
    Write-Host "  • Create customer/technician profiles" -ForegroundColor White
    Write-Host "  • Access admin panel at http://localhost:5173" -ForegroundColor White
    Write-Host "`nNext steps:" -ForegroundColor Yellow
    Write-Host "  1. Get Google Maps API key" -ForegroundColor White
    Write-Host "  2. Update .env files with real API key" -ForegroundColor White
    Write-Host "  3. (Optional) Set up Firebase for notifications" -ForegroundColor White
    Write-Host "  4. Run: flutter run (in customer_app or technician_app)" -ForegroundColor White
} else {
    Write-Host "✗ Phase 1 Setup Incomplete" -ForegroundColor Red
    Write-Host "`nPlease fix the issues above and run this script again." -ForegroundColor Yellow
    Write-Host "See docs/PHASE1_SETUP_GUIDE.md for detailed instructions." -ForegroundColor Yellow
}
Write-Host "==================================" -ForegroundColor Cyan
