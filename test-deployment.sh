#!/bin/bash
# Test script to verify Apache deployment and admin route

echo "🧪 Testing AureusERP deployment..."
echo ""

echo "1️⃣ Testing /admin route..."
response=$(curl -s -o /dev/null -w "%{http_code}" -k https://aureus.abcotronics.co.za/admin)
echo "   Status code: $response"

if [ "$response" == "200" ] || [ "$response" == "302" ]; then
    echo "   ✅ SUCCESS! Admin route is working!"
elif [ "$response" == "404" ]; then
    echo "   ❌ FAILED: Still getting 404"
else
    echo "   ⚠️  Got response: $response"
fi

echo ""
echo "2️⃣ Checking if it's Apache or nginx..."
server=$(curl -s -I -k https://aureus.abcotronics.co.za/admin | grep -i "Server:" || echo "Server header not found")
echo "   $server"

echo ""
echo "3️⃣ Testing homepage..."
home_response=$(curl -s -o /dev/null -w "%{http_code}" -k https://aureus.abcotronics.co.za/)
echo "   Homepage status: $home_response"

echo ""
echo "4️⃣ Checking for nginx 404 page..."
content=$(curl -s -k https://aureus.abcotronics.co.za/admin)
if echo "$content" | grep -q "<center>nginx</center>"; then
    echo "   ❌ NGINX is still serving the page!"
    echo "   → Pod hasn't restarted yet. Wait a bit longer."
elif echo "$content" | grep -q "Filament" || echo "$content" | grep -q "login"; then
    echo "   ✅ Laravel/Filament is responding!"
    echo "   → Apache is working correctly!"
else
    echo "   ⚠️  Got unexpected response. Check manually in browser."
fi

echo ""
echo "5️⃣ Testing customer panel path..."
customer_response=$(curl -s -o /dev/null -w "%{http_code}" -k https://aureus.abcotronics.co.za/customer)
echo "   Customer panel status: $customer_response"
if [ "$customer_response" == "200" ] || [ "$customer_response" == "302" ]; then
    echo "   ✅ Customer panel is accessible"
else
    echo "   ⚠️  Customer panel returned: $customer_response"
fi

echo ""
echo "🌐 URLs to test in browser:"
echo "   Admin Panel:    https://aureus.abcotronics.co.za/admin"
echo "   Customer Panel: https://aureus.abcotronics.co.za/customer"

