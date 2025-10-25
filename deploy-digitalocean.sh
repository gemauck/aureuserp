#!/bin/bash

# Digital Ocean Deployment Script for AureusERP
# This script sets up the .env file and runs necessary commands

echo "🚀 Starting Digital Ocean deployment setup..."

# Navigate to workspace
cd /workspace

# Create .env file
echo "📝 Creating .env file..."
cat > .env << 'ENVFILE'
APP_NAME="AureusERP"
APP_ENV=production
APP_DEBUG=false
APP_TIMEZONE=UTC
APP_URL=${APP_URL}

LOG_CHANNEL=stack
LOG_LEVEL=error

DB_CONNECTION=${DB_CONNECTION}
DB_HOST=${DB_HOST}
DB_PORT=${DB_PORT}
DB_DATABASE=${DB_DATABASE}
DB_USERNAME=${DB_USERNAME}
DB_PASSWORD=${DB_PASSWORD}

SESSION_DRIVER=database
SESSION_LIFETIME=120
SESSION_ENCRYPT=false

CACHE_STORE=database
QUEUE_CONNECTION=database

FILESYSTEM_DISK=local
BROADCAST_CONNECTION=log

MAIL_MAILER=log
MAIL_FROM_ADDRESS="noreply@aureuserp.com"
MAIL_FROM_NAME="AureusERP"
ENVFILE

# Set proper permissions
chmod 644 .env

# Generate app key
echo "🔑 Generating application key..."
php artisan key:generate --force

# Clear caches
echo "🧹 Clearing caches..."
php artisan config:clear
php artisan cache:clear
php artisan route:clear
php artisan view:clear

# Run migrations
echo "🗄️  Running database migrations..."
php artisan migrate --force

# Optimize for production
echo "⚡ Optimizing for production..."
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan filament:optimize
php artisan optimize

# Link storage
echo "🔗 Linking storage..."
php artisan storage:link

# Set proper permissions for storage and cache
echo "🔒 Setting permissions..."
chmod -R 775 storage bootstrap/cache 2>/dev/null || true

echo "✅ Deployment setup complete!"
echo ""
echo "Your application should now be running properly."

