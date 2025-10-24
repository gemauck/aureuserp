#!/bin/bash

set -e

echo "Running post-deployment setup..."

cd /workspace

# Regenerate autoloader
echo "1. Regenerating autoloader..."
composer dump-autoload --optimize

# Discover packages
echo "2. Discovering packages..."
php artisan package:discover || true

# Clear caches
echo "3. Clearing caches..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Run migrations
echo "4. Running migrations..."
php artisan migrate --force

# Optimize for production
echo "5. Optimizing..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan optimize

echo "✅ Deployment setup complete!"

