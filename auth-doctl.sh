#!/bin/bash
# Authenticate doctl and test your app

echo "🔐 DigitalOcean CLI Authentication"
echo "===================================="
echo ""
echo "📋 Step 1: Get your API token"
echo ""
echo "   1. Open: https://cloud.digitalocean.com/account/api/tokens"
echo "   2. Click 'Generate New Token'"
echo "   3. Name it 'doctl-cli' (or similar)"
echo "   4. Enable Read + Write permissions"
echo "   5. Click 'Generate Token'"
echo "   6. COPY the token (you'll only see it once!)"
echo ""
read -p "Press Enter when you have your token ready..."
echo ""

echo "🔧 Step 2: Authenticate"
echo ""
echo "Running: doctl auth init"
echo ""
echo "When prompted, paste your API token and press Enter:"
echo ""

# Run authentication
~/bin/doctl auth init

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Authentication successful!"
    echo ""
    echo "🧪 Step 3: Testing your app..."
    echo ""
    
    # List apps
    echo "📱 Your DigitalOcean Apps:"
    ~/bin/doctl apps list
    
    echo ""
    echo "✅ doctl is ready to use!"
    echo ""
    echo "💡 Useful commands:"
    echo "   doctl apps list                           - List all apps"
    echo "   doctl apps get walrus-app-yna2h           - Get app details"
    echo "   doctl apps logs walrus-app-yna2h          - View logs"
    echo "   doctl apps create-deployment walrus-app-yna2h  - Force redeploy"
    echo ""
else
    echo ""
    echo "❌ Authentication failed"
    echo ""
    echo "Please check:"
    echo "   - You copied the entire token"
    echo "   - Token has Read + Write permissions"
    echo "   - Token hasn't expired"
    echo ""
    echo "Try again by running: ./auth-doctl.sh"
    echo ""
fi

