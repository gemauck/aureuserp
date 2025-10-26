#!/bin/bash
# Deploy the 404 fix to DigitalOcean
# This script commits and pushes the changes

echo "🚀 Deploying 404 Fix"
echo "================================"
echo ""

# Check if we're in a git repository
if [ ! -d .git ]; then
    echo "❌ Error: Not in a git repository"
    exit 1
fi

# Check git status
echo "📊 Current git status:"
git status --short
echo ""

# Show what changed
echo "📝 Changes made:"
echo "1. ✓ CustomerPanel path changed from '/' to '/customer'"
echo "   - This prevents conflicts with admin routes"
echo "   - Customer portal will now be at: /customer"
echo ""
echo "2. ✓ Routes cleaned up in web.php"
echo ""

# Ask for confirmation
read -p "Do you want to commit and push these changes? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Deployment cancelled"
    exit 0
fi

echo ""
echo "📦 Committing changes..."

# Stage the changes
git add app/Providers/Filament/CustomerPanelProvider.php
git add routes/web.php

# Commit
git commit -m "Fix 404 error: Change CustomerPanel path to avoid conflicts

- Changed CustomerPanel path from '/' to '/customer'
- This prevents the customer panel from interfering with admin routes
- Admin panel remains at '/admin'
- Customer portal now accessible at '/customer'

Fixes: 404 errors on /admin route"

echo ""
echo "📤 Pushing to remote..."
git push origin master

echo ""
echo "✅ Changes deployed!"
echo ""
echo "⏳ NEXT STEPS:"
echo "================================"
echo ""
echo "1. Wait 5-10 minutes for DigitalOcean to rebuild and deploy"
echo ""
echo "2. Access your DigitalOcean App Console and run:"
echo "   php artisan optimize:clear"
echo "   php artisan config:cache"
echo "   php artisan route:cache"
echo ""
echo "3. Test the deployment:"
echo "   bash test-deployment.sh"
echo ""
echo "📌 Important URLs after deployment:"
echo "   - Admin Panel: https://aureus.abcotronics.co.za/admin"
echo "   - Customer Portal: https://aureus.abcotronics.co.za/customer"
echo ""
echo "If still seeing 404 after deployment completes,"
echo "run: bash fix-404.sh for additional troubleshooting."
echo ""

