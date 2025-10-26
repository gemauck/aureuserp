#!/bin/bash
# Startup script that runs before Apache starts
# This ensures routes are always registered

echo "🚀 AureusERP Startup Script"
echo "=========================="

# Run Laravel optimization commands
echo "📦 Discovering packages..."
php artisan package:discover --ansi || echo "⚠️ package:discover failed"

echo "🔄 Clearing caches..."
php artisan optimize:clear || echo "⚠️ optimize:clear failed"

echo "⚙️ Caching configuration..."
php artisan config:cache || echo "⚠️ config:cache failed"

echo "🗺️ Caching routes..."
php artisan route:cache || echo "⚠️ route:cache failed"

echo "✨ Optimizing Filament..."
php artisan filament:optimize || echo "⚠️ filament:optimize failed"

echo "✅ Startup complete! Starting Apache..."
echo ""

# Start Apache
exec vendor/bin/heroku-php-apache2 public/

