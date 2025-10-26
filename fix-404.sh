#!/bin/bash
# Comprehensive 404 Fix Script for AureusERP
# This script diagnoses and attempts to fix the 404 issue

echo "🔧 AureusERP 404 Fix Script"
echo "================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
APP_URL="https://aureus.abcotronics.co.za"
DOCTL_APP_ID="" # Add your DigitalOcean App ID if using doctl

# Test function
test_url() {
    local url=$1
    local description=$2
    echo -n "Testing $description... "
    response=$(curl -s -o /dev/null -w "%{http_code}" -L -k "$url" 2>/dev/null)
    
    if [ "$response" == "200" ] || [ "$response" == "302" ]; then
        echo -e "${GREEN}✓${NC} ($response)"
        return 0
    elif [ "$response" == "404" ]; then
        echo -e "${RED}✗ 404${NC}"
        return 1
    else
        echo -e "${YELLOW}? ${response}${NC}"
        return 2
    fi
}

# Step 1: Diagnose current state
echo "📊 DIAGNOSIS"
echo "================================"
echo ""

test_url "$APP_URL/" "Homepage"
admin_result=$?
test_url "$APP_URL/admin" "Admin Panel"
test_url "$APP_URL/admin/login" "Admin Login"

echo ""
echo "Checking server type..."
server_header=$(curl -s -I -k "$APP_URL/admin" 2>/dev/null | grep -i "^Server:" | cut -d' ' -f2-)
if [ -n "$server_header" ]; then
    echo "Server: $server_header"
else
    echo "Server: Unknown (header not exposed)"
fi

echo ""
echo "Checking response content..."
content=$(curl -s -k "$APP_URL/admin" 2>/dev/null | head -n 20)
if echo "$content" | grep -qi "nginx"; then
    echo -e "${RED}⚠️  Response contains 'nginx' - still showing nginx 404 page${NC}"
    echo -e "${YELLOW}   → Laravel is NOT receiving requests${NC}"
elif echo "$content" | grep -qi "laravel\|filament\|login"; then
    echo -e "${GREEN}✓ Response contains Laravel/Filament content${NC}"
    echo -e "${GREEN}   → Laravel IS receiving requests${NC}"
else
    echo -e "${YELLOW}? Cannot determine - check manually${NC}"
fi

echo ""
echo ""

# Step 2: Provide fix instructions
echo "🔧 RECOMMENDED FIXES"
echo "================================"
echo ""

echo "Fix #1: Clear Application Cache (CRITICAL)"
echo "-------------------------------------------"
echo "Run these commands in your DigitalOcean console or via SSH:"
echo ""
echo -e "${YELLOW}# Connect to your app console first, then run:${NC}"
echo ""
echo "php artisan optimize:clear"
echo "php artisan route:clear"
echo "php artisan config:clear"
echo "php artisan view:clear"
echo "php artisan cache:clear"
echo ""
echo "# Then recache for production:"
echo "php artisan config:cache"
echo "php artisan route:cache"
echo "php artisan filament:optimize"
echo ""

echo "Fix #2: Restart the Application"
echo "-------------------------------------------"
echo "In DigitalOcean App Platform:"
echo "1. Go to your app dashboard"
echo "2. Click 'Actions' → 'Force Rebuild and Deploy'"
echo "3. Wait for deployment to complete (5-10 minutes)"
echo ""

echo "Fix #3: Fix Panel Path Conflict (RECOMMENDED)"
echo "-------------------------------------------"
echo "Your CustomerPanel at '/' may be interfering with admin routes."
echo ""
echo -e "${YELLOW}Change CustomerPanel path from '/' to '/customer' or '/portal'${NC}"
echo ""
echo "Edit: app/Providers/Filament/CustomerPanelProvider.php"
echo "Change line 25 from:"
echo "    ->path('/')"
echo "To:"
echo "    ->path('customer')"
echo ""
echo "Then redeploy."
echo ""

echo "Fix #4: Verify Environment Variables"
echo "-------------------------------------------"
echo "Ensure these are set in DigitalOcean App Platform:"
echo "- APP_KEY (must be set!)"
echo "- APP_URL=$APP_URL"
echo "- APP_ENV=production"
echo "- APP_DEBUG=false"
echo ""

echo ""
echo "📋 QUICK ACTION CHECKLIST"
echo "================================"
echo ""
echo "[ ] 1. Access DigitalOcean console for your app"
echo "[ ] 2. Run 'php artisan optimize:clear'"
echo "[ ] 3. Run 'php artisan config:cache && php artisan route:cache'"
echo "[ ] 4. Force rebuild and deploy in DigitalOcean"
echo "[ ] 5. Wait 5-10 minutes for deployment"
echo "[ ] 6. Run this script again to verify"
echo "[ ] 7. If still 404, apply Fix #3 (change customer panel path)"
echo ""

# Step 3: Generate commands for easy copy-paste
echo ""
echo "📝 COPY-PASTE COMMANDS FOR CONSOLE"
echo "================================"
echo ""
cat << 'COMMANDS'
# Paste this entire block into your DigitalOcean app console:

echo "Clearing all caches..."
php artisan optimize:clear
php artisan route:clear
php artisan config:clear
php artisan view:clear
php artisan cache:clear

echo "Recaching for production..."
php artisan config:cache
php artisan route:cache
php artisan filament:optimize

echo "Checking routes..."
php artisan route:list | grep admin | head -n 10

echo "Done! Now redeploy the app in DigitalOcean dashboard."
COMMANDS

echo ""
echo ""
echo "🔗 Test again after fixes:"
echo "   bash fix-404.sh"
echo ""

