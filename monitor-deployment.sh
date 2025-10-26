#!/bin/bash
# Monitor your DigitalOcean deployment

URL="https://walrus-app-yna2h.ondigitalocean.app"

echo "🔍 Monitoring AureusERP Deployment..."
echo "======================================"
echo ""
echo "URL: $URL"
echo ""

# Function to test the app
test_app() {
    echo "🧪 Testing..."
    
    response=$(curl -s -o /dev/null -w "%{http_code}" -L "$URL/admin")
    server=$(curl -s -I "$URL/admin" 2>/dev/null | grep -i "^server:" | cut -d: -f2 | xargs)
    
    echo "   Status: $response"
    echo "   Server: ${server:-Not detected}"
    
    if [ "$response" == "200" ] || [ "$response" == "302" ]; then
        echo "   ✅ SUCCESS! App is working!"
        return 0
    elif [ "$response" == "404" ]; then
        echo "   ⏳ Deployment in progress or needs configuration..."
        return 1
    else
        echo "   ⚠️  Unexpected response: $response"
        return 1
    fi
}

# Test once to show current status
test_app
echo ""
echo "⏱️  Waiting for deployment to complete (2-5 minutes)..."
echo ""
echo "💡 Check DigitalOcean dashboard for build progress:"
echo "   https://cloud.digitalocean.com/apps"
echo ""
echo "Press Ctrl+C to stop monitoring"
echo ""

# Keep testing every 30 seconds
while true; do
    sleep 30
    clear
    echo "🔍 AureusERP Deployment Status"
    echo "======================================"
    test_app
    echo ""
    echo "⏱️  Checking again in 30 seconds..."
done

