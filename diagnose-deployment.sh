#!/bin/bash
# Comprehensive Deployment Diagnostics
# This script helps identify why EVERYTHING is returning 404

echo "🔍 AureusERP Deployment Diagnostics"
echo "===================================="
echo ""

APP_URL="https://aureus.abcotronics.co.za"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}📊 SERVER INFORMATION${NC}"
echo "------------------------------------"
echo "Testing server headers..."
curl -sI "$APP_URL" | head -n 15
echo ""

echo -e "${BLUE}🌐 CONNECTIVITY TESTS${NC}"
echo "------------------------------------"
echo "Testing various paths..."

test_path() {
    local path=$1
    local name=$2
    local code=$(curl -s -o /dev/null -w "%{http_code}" -k "$APP_URL$path" 2>/dev/null)
    
    printf "%-20s " "$name:"
    if [ "$code" == "200" ] || [ "$code" == "302" ]; then
        echo -e "${GREEN}$code ✓${NC}"
    elif [ "$code" == "404" ]; then
        echo -e "${RED}404 ✗${NC}"
    else
        echo -e "${YELLOW}$code${NC}"
    fi
}

test_path "/" "Homepage"
test_path "/admin" "Admin panel"
test_path "/admin/login" "Admin login"
test_path "/customer" "Customer panel"
test_path "/index.php" "index.php direct"
test_path "/favicon.ico" "Static file"
test_path "/css/filament/filament.css" "CSS asset"

echo ""
echo -e "${BLUE}📄 RESPONSE CONTENT ANALYSIS${NC}"
echo "------------------------------------"
echo "Fetching homepage content..."
content=$(curl -s -k "$APP_URL" 2>/dev/null)

if [ -z "$content" ]; then
    echo -e "${RED}⚠️  Empty response - server may not be running${NC}"
elif echo "$content" | grep -qi "nginx"; then
    echo -e "${YELLOW}⚠️  nginx error page detected${NC}"
    echo "   → nginx is serving errors, not passing to application"
elif echo "$content" | grep -qi "litespeed"; then
    echo -e "${YELLOW}⚠️  LiteSpeed error page detected${NC}"
    echo "   → LiteSpeed can't find the application"
elif echo "$content" | grep -qi "apache"; then
    echo -e "${YELLOW}⚠️  Apache error page detected${NC}"
    echo "   → Apache configuration issue"
elif echo "$content" | grep -qi "laravel\|filament"; then
    echo -e "${GREEN}✓ Laravel/Filament content detected${NC}"
    echo "   → Application is responding correctly"
elif echo "$content" | grep -qi "<!DOCTYPE html>"; then
    echo -e "${YELLOW}? HTML content found (unknown)${NC}"
    echo "First 200 characters:"
    echo "$content" | head -c 200
else
    echo -e "${RED}? Unknown response format${NC}"
    echo "First 200 characters:"
    echo "$content" | head -c 200
fi

echo ""
echo ""
echo -e "${BLUE}🔧 LIKELY ISSUES${NC}"
echo "===================================="
echo ""

# Determine the most likely issue
all_404=true
if curl -s -o /dev/null -w "%{http_code}" -k "$APP_URL/index.php" | grep -q "200\|302"; then
    all_404=false
fi

if [ "$all_404" = true ]; then
    echo -e "${RED}Issue: ALL routes return 404${NC}"
    echo ""
    echo "This indicates a FUNDAMENTAL deployment problem, not just a routing issue."
    echo ""
    echo "Possible causes:"
    echo ""
    echo "1. ${YELLOW}Application Not Deployed${NC}"
    echo "   - DigitalOcean/hosting platform deployment failed"
    echo "   - Check deployment logs in your hosting dashboard"
    echo "   - Verify build completed successfully"
    echo ""
    echo "2. ${YELLOW}Document Root Incorrect${NC}"
    echo "   - Server is looking in wrong directory"
    echo "   - Should point to: /workspace/public or /app/public"
    echo "   - Current setting might be pointing to root directory"
    echo ""
    echo "3. ${YELLOW}Application Not Running${NC}"
    echo "   - PHP-FPM or application server not started"
    echo "   - Check if PHP is processing files"
    echo "   - Verify Procfile is correct"
    echo ""
    echo "4. ${YELLOW}Missing Dependencies${NC}"
    echo "   - Composer install failed"
    echo "   - vendor/ directory not present"
    echo "   - Check build logs for errors"
    echo ""
    echo "5. ${YELLOW}File Permissions${NC}"
    echo "   - Web server can't read files"
    echo "   - public/ directory not accessible"
    echo ""
else
    echo -e "${YELLOW}Partial Success: Some routes may work${NC}"
    echo "Check individual routes above for details."
fi

echo ""
echo -e "${BLUE}📋 IMMEDIATE ACTION ITEMS${NC}"
echo "===================================="
echo ""
echo "1. ${YELLOW}Check Hosting Dashboard${NC}"
echo "   • Go to your DigitalOcean/hosting dashboard"
echo "   • Check deployment status - is it 'Running'?"
echo "   • Look for any error messages in logs"
echo "   • Verify the app is actually deployed"
echo ""
echo "2. ${YELLOW}Verify Deployment Logs${NC}"
echo "   • Check build logs for errors"
echo "   • Look for 'composer install' failures"
echo "   • Check for PHP version compatibility issues"
echo "   • Verify all dependencies installed"
echo ""
echo "3. ${YELLOW}Check Document Root${NC}"
echo "   • Ensure document root points to 'public/' directory"
echo "   • Path should be: /workspace/public or /app/public"
echo "   • NOT: /workspace or /app"
echo ""
echo "4. ${YELLOW}Verify Procfile${NC}"
echo "   • Should contain: web: vendor/bin/heroku-php-apache2 public/"
echo "   • Or for LiteSpeed: may need different configuration"
echo "   • Check hosting platform documentation"
echo ""
echo "5. ${YELLOW}Test Console Access${NC}"
echo "   • Access your app console/SSH"
echo "   • Run: php artisan about"
echo "   • Run: ls -la public/"
echo "   • Run: php artisan route:list"
echo "   • If any of these fail, Laravel isn't properly set up"
echo ""

echo -e "${BLUE}🔗 HELPFUL COMMANDS${NC}"
echo "===================================="
echo ""
echo "If you can access the console, run these:"
echo ""
cat << 'EOF'
# Check if Laravel is working
php artisan about

# Check if routes are registered
php artisan route:list | head -n 20

# Check file permissions
ls -la public/
ls -la storage/

# Check if vendor directory exists
ls -la vendor/ | head -n 10

# Check environment
php artisan env
printenv | grep APP_

# Test PHP is working
php -v
php -r "echo 'PHP is working\n';"

# Check composer dependencies
composer check-platform-reqs
EOF

echo ""
echo ""
echo -e "${BLUE}💡 NEXT STEPS${NC}"
echo "===================================="
echo ""
echo "Based on the 404s on ALL routes, this is NOT a simple routing issue."
echo "You need to:"
echo ""
echo "1. Check your hosting platform dashboard for deployment status"
echo "2. Look at deployment/build logs for any errors"
echo "3. Verify the application actually deployed successfully"
echo "4. Check document root configuration"
echo "5. If on DigitalOcean App Platform, try 'Force Rebuild and Deploy'"
echo ""
echo "Once the deployment is actually running, THEN we can address"
echo "the panel path conflicts and route caching issues."
echo ""

