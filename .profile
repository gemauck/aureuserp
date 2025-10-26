#!/bin/bash
# Startup script - runs migrations and optimizations

echo "🚀 Running startup tasks..."

# Run migrations
echo "📦 Running migrations..."
php artisan migrate --force 2>&1 || echo "Warning: Migration issues"

# Clear caches
echo "🧹 Clearing caches..."
rm -rf bootstrap/cache/*.php 2>/dev/null || true

echo "✅ Startup complete!"

