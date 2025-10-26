# Deployment Notes for AureusERP

## Current Configuration

### Primary Approach: Custom nginx
- **Procfile**: Uses `vendor/bin/heroku-php-nginx -C nginx-custom.conf public/`
- **Config**: `nginx-custom.conf` contains location blocks with Laravel routing fix
- **Key directive**: `try_files $uri $uri/ /index.php?$query_string;`

## If nginx Approach Still Shows 404 Errors

### Problem: Heroku's -C Flag Limitation
The `-C` flag **includes** custom config but doesn't **replace** default config. This means:
- Default `location /` blocks from `default_include.conf` might still take precedence
- nginx uses the FIRST matching location block it finds

### Solution 1: Switch to Apache (Recommended Fallback)

Apache's `.htaccess` file in `public/` will automatically handle Laravel routing correctly.

**Steps:**
1. Rename `Procfile` to `Procfile.nginx` (backup)
2. Copy `Procfile.apache` to `Procfile`:
   ```bash
   cp Procfile.apache Procfile
   ```
3. Commit and push:
   ```bash
   git add Procfile Procfile.nginx
   git commit -m "Switch to Apache for proper Laravel routing"
   git push
   ```

Apache is often simpler for Laravel apps and the `.htaccess` file we have works perfectly.

### Solution 2: Custom Buildpack with nginx Override

If you MUST use nginx, you can create a custom buildpack or use a hook script:

**Create `.profile.d/nginx-fix.sh`:**
```bash
#!/bin/bash
# This runs after deployment but before nginx starts
cat > /app/vendor/heroku/heroku-buildpack-php/conf/nginx/default_include.conf << 'EOF'
location / {
    index index.php index.html index.htm;
    try_files $uri $uri/ /index.php?$query_string;
}
EOF
```

Then commit:
```bash
mkdir -p .profile.d
# Create the file above
git add .profile.d/nginx-fix.sh
git commit -m "Add nginx override hook"
git push
```

### Solution 3: Verify Current nginx Config in Production

SSH into your production container and check:

```bash
# View actual nginx configuration being used
cat /etc/nginx/conf.d/default.conf

# Check if your custom config is being included
grep -r "try_files" /app/vendor/heroku/heroku-buildpack-php/conf/nginx/

# Test nginx configuration
nginx -t
```

## Testing Checklist

After deployment, verify:

1. **Route listing**:
   ```bash
   php artisan route:list | grep admin
   ```
   Should show Filament admin routes.

2. **Test URLs**:
   ```bash
   curl -I https://your-app.com/admin
   # Should return 200 or 302 (redirect to login)
   ```

3. **Check Laravel is receiving requests**:
   ```bash
   tail -f storage/logs/laravel.log
   # Then access /admin in browser
   # Should see log entries if Laravel received the request
   ```

4. **If still getting plain nginx 404**:
   - Laravel is NOT receiving the request
   - nginx is returning 404 before reaching PHP
   - The nginx config is NOT correctly applied
   - → Switch to Apache (Solution 1)

## Environment Variables to Check

Ensure these are set in your hosting platform:

```bash
APP_NAME="AureusERP"
APP_ENV=production
APP_DEBUG=false
APP_KEY=base64:xxxxxxxxxxxxx  # Must be set!
APP_URL=https://your-actual-domain.com

DB_CONNECTION=mysql
DB_HOST=your-db-host
DB_PORT=3306
DB_DATABASE=your-db-name
DB_USERNAME=your-db-user
DB_PASSWORD=your-db-password

SESSION_DRIVER=database
CACHE_STORE=database
QUEUE_CONNECTION=database
```

## Quick Reference: Deployment Commands

```bash
# After deployment, run in production:
php artisan optimize:clear
php artisan migrate --force
php artisan filament:optimize
php artisan config:cache
php artisan route:cache
```

## Support

If issues persist after trying these solutions, check:
1. `404-troubleshooting-guide.md` - Comprehensive troubleshooting
2. Heroku/DigitalOcean logs for deployment errors
3. Laravel logs in `storage/logs/laravel.log`

---

**Last Updated**: October 26, 2025

