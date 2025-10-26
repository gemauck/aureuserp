#!/bin/bash
# Simple script to test and fix your deployment

echo "🔍 AureusERP Deployment Fixer"
echo "================================"
echo ""

echo "📍 Step 1: Find your DigitalOcean URL"
echo ""
echo "   1. Open: https://cloud.digitalocean.com/apps"
echo "   2. Click on your AureusERP app"
echo "   3. Copy the URL (looks like: aureuserp-xxxxx.ondigitalocean.app)"
echo ""
read -p "   Paste your DigitalOcean URL here (without https://): " DO_URL

if [ -z "$DO_URL" ]; then
    echo "❌ No URL provided. Please run the script again."
    exit 1
fi

# Remove https:// if user included it
DO_URL=$(echo $DO_URL | sed 's|https://||' | sed 's|http://||' | sed 's|/$||')

echo ""
echo "================================"
echo "🧪 Step 2: Testing DigitalOcean deployment..."
echo ""

# Test the /admin route
echo "Testing: https://$DO_URL/admin"
response=$(curl -s -o /dev/null -w "%{http_code}" -L https://$DO_URL/admin)

echo "   Response code: $response"

if [ "$response" == "200" ]; then
    echo "   ✅ SUCCESS! Your DigitalOcean app is working!"
    echo ""
    echo "================================"
    echo "🎯 Step 3: Update Your DNS"
    echo ""
    echo "Your app is working on DigitalOcean! Now update your DNS:"
    echo ""
    echo "   1. Go to your DNS provider (where abcotronics.co.za is managed)"
    echo "   2. Find DNS records for: aureus.abcotronics.co.za"
    echo "   3. Change it to:"
    echo ""
    echo "      Type:  CNAME"
    echo "      Name:  aureus"
    echo "      Value: $DO_URL"
    echo "      TTL:   3600"
    echo ""
    echo "   4. Save and wait 10-15 minutes"
    echo ""
    echo "================================"
    echo "✅ After DNS updates, test:"
    echo "   https://aureus.abcotronics.co.za/admin"
    echo ""
    
elif [ "$response" == "302" ]; then
    echo "   ✅ SUCCESS! Your app is working (redirecting to login)"
    echo ""
    echo "================================"
    echo "🎯 Step 3: Update Your DNS"
    echo ""
    echo "Your app is working on DigitalOcean! Now update your DNS:"
    echo ""
    echo "   1. Go to your DNS provider (where abcotronics.co.za is managed)"
    echo "   2. Find DNS records for: aureus.abcotronics.co.za"
    echo "   3. Change it to:"
    echo ""
    echo "      Type:  CNAME"
    echo "      Name:  aureus"
    echo "      Value: $DO_URL"
    echo "      TTL:   3600"
    echo ""
    echo "   4. Save and wait 10-15 minutes"
    echo ""
    echo "================================"
    echo "✅ After DNS updates, test:"
    echo "   https://aureus.abcotronics.co.za/admin"
    echo ""
    
elif [ "$response" == "404" ]; then
    echo "   ⚠️  Getting 404 on DigitalOcean too"
    echo ""
    echo "Let me check what server is responding..."
    server=$(curl -s -I https://$DO_URL/admin | grep -i "server:" | cut -d: -f2 | xargs)
    echo "   Server: $server"
    echo ""
    
    if [[ "$server" == *"nginx"* ]] || [[ "$server" == *"Apache"* ]]; then
        echo "   ℹ️  The server is responding, but Laravel routing might not be set up."
        echo ""
        echo "   🔧 Try accessing the DigitalOcean console and run:"
        echo "      php artisan route:list | grep admin"
        echo "      php artisan optimize:clear"
        echo ""
    else
        echo "   ⚠️  Unexpected server type: $server"
    fi
    
else
    echo "   ⚠️  Unexpected response: $response"
    echo ""
    echo "   Try opening this in your browser:"
    echo "   https://$DO_URL/admin"
fi

echo ""
echo "================================"
echo "📖 For detailed instructions, see: FIX-DNS-GUIDE.md"
echo ""

