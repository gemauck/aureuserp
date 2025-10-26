#!/bin/bash
# Run migrations then start Apache
php artisan migrate --force 2>&1 || echo "Migration warning"
exec vendor/bin/heroku-php-apache2 public/

