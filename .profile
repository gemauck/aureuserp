#!/bin/bash
# This runs on every container startup
# Ensures Laravel is properly optimized

echo "🚀 Running Laravel optimization commands..."

# Clear all caches first
php artisan optimize:clear

# Discover packages (registers Filament routes)
php artisan package:discover --ansi

# Cache for performance
php artisan config:cache
php artisan route:cache

# Optimize Filament
php artisan filament:optimize || true

echo "✅ Laravel optimization complete!"

