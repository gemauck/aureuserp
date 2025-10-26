#!/bin/bash
# Start Apache immediately, run migrations in background with timeout

# Start migrations in background with 60 second timeout
(
  timeout 60 php artisan migrate --force 2>&1 || true
) &

# Start Apache immediately (don't wait for migrations)
exec vendor/bin/heroku-php-apache2 public/

