web: vendor/bin/heroku-php-nginx -C nginx.conf public/
release: php artisan migrate --force && php artisan config:cache && php artisan optimize

