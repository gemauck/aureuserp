# 404 Error Troubleshooting Guide for AureusERP

## ✅ Already Fixed
- **nginx configuration**: Added `try_files` directive to route requests through Laravel

---

## 🔍 Other Potential Causes for 404 Errors

### 1. **Environment Configuration Issues** ⚠️ HIGH PRIORITY

#### APP_URL Mismatch
**Problem**: If `APP_URL` doesn't match your actual domain, asset URLs and redirects may fail.

**Check in production:**
```bash
# In your pod/container
echo $APP_URL
```

**Should be**: Your actual domain (e.g., `https://yourapp.example.com`)

**Fix**: Set the correct environment variable in your hosting platform:
```bash
APP_URL=https://your-actual-domain.com
```

#### APP_KEY Missing
**Problem**: Laravel won't run properly without an encryption key.

**Check**:
```bash
echo $APP_KEY
```

**Fix**: Generate and set it in your environment variables:
```bash
php artisan key:generate --show
```

---

### 2. **Cache Issues** ⚠️ MEDIUM PRIORITY

#### Cached Routes/Config
**Problem**: Old cached routes or config can cause 404s even after code updates.

**Symptoms**:
- Changes to routes don't take effect
- New routes return 404

**Fix - Run in production after each deployment:**
```bash
php artisan optimize:clear
# OR individually:
php artisan route:clear
php artisan config:clear
php artisan view:clear
php artisan cache:clear
```

**Add to your deployment script**:
```bash
# In deploy-digitalocean.sh or similar
php artisan migrate --force
php artisan optimize:clear
php artisan filament:optimize
```

---

### 3. **Database/Migration Issues** ⚠️ HIGH PRIORITY

#### Missing Tables
**Problem**: Filament Shield and other packages require specific tables.

**Check if migrations ran:**
```bash
php artisan migrate:status
```

**Look for these critical migrations:**
- `create_permission_tables` (for Filament Shield)
- `add_resource_permission_column_to_users_table`
- `create_settings_table`

**Fix**:
```bash
php artisan migrate --force
```

#### No Admin User
**Problem**: Can't login because no user exists with proper permissions.

**Fix - Create admin user:**
```bash
php artisan shield:super-admin
# Or manually:
php artisan tinker
>>> $user = User::first();
>>> $user->assignRole('super_admin');
```

---

### 4. **File Permissions** ⚠️ MEDIUM PRIORITY

#### Storage/Bootstrap Cache Not Writable
**Problem**: Laravel needs write access to certain directories.

**Symptoms**:
- 500 errors
- Logs not writing
- Views not caching

**Check permissions in production:**
```bash
ls -la storage/
ls -la bootstrap/cache/
```

**Fix**:
```bash
chmod -R 775 storage bootstrap/cache
chown -R www-data:www-data storage bootstrap/cache
```

---

### 5. **Composer Autoload Issues** ⚠️ LOW PRIORITY

#### Plugin Classes Not Found
**Problem**: The `composer-merge-plugin` needs to merge all plugin composer.json files.

**Symptoms**:
- Class not found errors
- Plugins not loading

**Fix**:
```bash
composer dump-autoload --optimize
php artisan package:discover --ansi
```

---

### 6. **Panel Path Conflicts** ⚠️ MEDIUM PRIORITY

**Current Configuration Detected:**
- **AdminPanel**: `/admin` (default panel) ✅
- **CustomerPanel**: `/` (root path) ⚠️

**Potential Issue**: CustomerPanel at `/` might interfere with admin routes.

**Test**:
1. Try accessing `/admin` - should show admin login
2. Try accessing `/` - should show customer panel
3. Try accessing `/admin/dashboard` after login

**Fix if needed** - Update `CustomerPanelProvider.php`:
```php
->path('customer')  // Instead of '/'
```

---

### 7. **Asset Compilation Issues** ⚠️ LOW PRIORITY

#### Missing Compiled Assets
**Problem**: Vite/Mix assets not compiled for production.

**Check**:
```bash
ls -la public/build/
```

**Fix - Add to deployment:**
```bash
npm install
npm run build
```

---

### 8. **Middleware Issues** ⚠️ LOW PRIORITY

#### Authentication Redirects
**Problem**: Unauthenticated users redirected to wrong login page.

**Check** `routes/web.php` - Current code:
```php
if (! request()->getRequestUri() == '/login') {
    Route::redirect('/login', '/admin/login')
        ->name('login');
}
```

**Issue**: The condition `if (! request()->getRequestUri() == '/login')` is always true due to operator precedence.

**Fix**:
```php
<?php

use Illuminate\Support\Facades\Route;

Route::redirect('/login', '/admin/login')->name('login');
```

---

### 9. **Web Server Configuration** ⚠️ HIGH PRIORITY

#### nginx Config Not Applied
**Problem**: Even with correct `nginx_app.conf`, it might not be loaded.

**Verify in production pod:**
```bash
# Check if config is loaded
cat /etc/nginx/conf.d/default.conf
# OR
nginx -T | grep "try_files"
```

**Should see**: `try_files $uri $uri/ /index.php?$query_string;`

**Fix**: Verify your Procfile is correct:
```
web: vendor/bin/heroku-php-nginx -C nginx_app.conf public/
```

#### Document Root Wrong
**Problem**: nginx serving from wrong directory.

**Check**: Document root should be `/app/public` or similar.

**Fix in nginx_app.conf if needed**:
```nginx
root /app/public;
```

---

### 10. **Deployment Platform Specific Issues** ⚠️ VARIES

#### DigitalOcean App Platform
**Checklist**:
- ✅ Build command includes `composer install --optimize-autoloader --no-dev`
- ✅ Run command: Procfile or `heroku-php-nginx`
- ✅ Environment variables set (APP_KEY, APP_URL, DB credentials)
- ✅ Health checks configured
- ✅ HTTP routes configured (not HTTPS-only if testing)

#### Heroku
**Checklist**:
- ✅ Procfile present
- ✅ Buildpacks: PHP + Node.js (if using Vite)
- ✅ Config vars set
- ✅ Database addon connected

---

## 🧪 Testing Checklist

After deployment, test these URLs:

```bash
# Should all return 200 OK (or redirect to login):
curl -I https://your-app.com/
curl -I https://your-app.com/admin
curl -I https://your-app.com/admin/login

# Should return 404 (Laravel's styled 404):
curl -I https://your-app.com/nonexistent-route

# Should be blocked by nginx (403 or 404):
curl -I https://your-app.com/composer.json
curl -I https://your-app.com/.env
```

---

## 🚀 Recommended Deployment Script

Update your `deploy-digitalocean.sh`:

```bash
#!/bin/bash
set -e

echo "🚀 Starting deployment..."

# Install dependencies
composer install --optimize-autoloader --no-dev
npm install
npm run build

# Clear caches
php artisan optimize:clear

# Run migrations
php artisan migrate --force

# Optimize for production
php artisan config:cache
php artisan route:cache
php artisan view:cache
php artisan filament:optimize

# Set permissions
chmod -R 775 storage bootstrap/cache

echo "✅ Deployment complete!"
```

---

## 📝 Debug Commands

Run these in production to diagnose issues:

```bash
# Check Laravel is working
php artisan about

# List all registered routes
php artisan route:list | grep admin

# Check Filament panels
php artisan filament:list

# View environment
php artisan env

# Check database connection
php artisan db:show

# View logs
tail -f storage/logs/laravel.log
```

---

## 🔧 Common Fixes Summary

**Most Common Issues**:
1. ✅ **nginx config** - Already fixed
2. ⚠️ **Cache not cleared** - Run `php artisan optimize:clear`
3. ⚠️ **APP_URL wrong** - Set to actual domain
4. ⚠️ **Migrations not run** - Run `php artisan migrate --force`
5. ⚠️ **No admin user** - Create with `php artisan shield:super-admin`

---

## 📞 Next Steps

1. **Verify deployment** - Check if new nginx config is active
2. **Clear all caches** - Run optimize:clear after deployment
3. **Check environment** - Ensure APP_URL and APP_KEY are set
4. **Test routes** - Use curl or browser to test each URL
5. **Check logs** - View `storage/logs/laravel.log` for errors

---

**Created**: October 25, 2025
**For**: AureusERP Deployment on DigitalOcean/Heroku

