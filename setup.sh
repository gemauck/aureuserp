#!/bin/bash
# Post-deployment setup script
# Run this after each deployment: bash setup.sh

set -e

echo "🚀 Starting post-deployment setup..."

cd /workspace

echo "📦 Regenerating autoloader..."
composer dump-autoload --optimize --no-interaction

echo "🔍 Discovering packages..."
php artisan package:discover --ansi || echo "Package discovery completed with warnings"

echo "🧹 Clearing caches..."
php artisan config:clear --quiet
php artisan cache:clear --quiet
php artisan route:clear --quiet
php artisan view:clear --quiet

echo "🗄️  Running migrations..."
php artisan migrate --force --no-interaction

echo "⚡ Optimizing application..."
php artisan config:cache --quiet
php artisan route:cache --quiet
php artisan view:cache --quiet

echo "✅ Setup complete! Your application is ready."

