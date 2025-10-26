# 404 Error Fix for AureusERP

## Problem

You were experiencing 404 errors on `/admin` routes even after switching from nginx to Apache. The root cause was a **path conflict** between two Filament panels.

## Root Cause

The **CustomerPanel** was configured to use the root path (`/`), which interfered with the **AdminPanel** at `/admin`:

```php
// CustomerPanelProvider.php (OLD - CAUSING ISSUES)
->path('/')  // ❌ This conflicts with admin routes!
```

When Filament registers a panel at `/`, it can intercept or conflict with other routes, causing 404 errors on the admin panel.

## What Was Changed

### 1. Fixed CustomerPanel Path ✅

**File:** `app/Providers/Filament/CustomerPanelProvider.php`

```php
// BEFORE (causing conflicts)
->path('/')
->homeUrl(url('/'))

// AFTER (fixed)
->path('customer')
->homeUrl(url('/customer'))
```

**Result:** 
- Admin Panel: `https://aureus.abcotronics.co.za/admin` ✅
- Customer Portal: `https://aureus.abcotronics.co.za/customer` ✅
- No more path conflicts!

### 2. Cleaned Up Routes ✅

**File:** `routes/web.php`

- Kept the `/login` → `/admin/login` redirect
- Removed unnecessary conditions
- Simple, clean routing

## Deployment Instructions

### Option 1: Automatic Deployment (Recommended)

Run the deployment script:

```bash
bash deploy-fix.sh
```

This will:
1. Show you what changed
2. Commit the changes
3. Push to DigitalOcean
4. Give you next steps

### Option 2: Manual Deployment

```bash
# 1. Commit changes
git add app/Providers/Filament/CustomerPanelProvider.php routes/web.php
git commit -m "Fix 404: Change CustomerPanel path to avoid conflicts"
git push origin master

# 2. Wait for DigitalOcean to rebuild (5-10 minutes)

# 3. Access DigitalOcean App Console and clear cache
php artisan optimize:clear
php artisan config:cache
php artisan route:cache
php artisan filament:optimize
```

## After Deployment

### 1. Test the Deployment

```bash
bash test-deployment.sh
```

You should see:
- ✅ Admin route working (200 or 302)
- ✅ Laravel/Filament responding
- ✅ Customer panel accessible

### 2. Access Your Panels

- **Admin Panel:** https://aureus.abcotronics.co.za/admin
- **Customer Portal:** https://aureus.abcotronics.co.za/customer

### 3. If Still Getting 404

Run the comprehensive troubleshooting script:

```bash
bash fix-404.sh
```

This will:
- Diagnose the issue
- Check if Laravel is receiving requests
- Provide copy-paste commands to fix common issues
- Give you a step-by-step action plan

## Common Issues After Deployment

### Issue 1: Still Getting 404 After Push

**Cause:** Deployment hasn't completed yet, or cache not cleared.

**Solution:**
1. Wait 5-10 minutes for DigitalOcean to rebuild
2. Check deployment logs in DigitalOcean dashboard
3. Once deployed, access console and run:
   ```bash
   php artisan optimize:clear
   php artisan config:cache
   php artisan route:cache
   ```

### Issue 2: nginx 404 Page Still Showing

**Cause:** Application pod hasn't restarted yet.

**Solution:**
1. In DigitalOcean dashboard: **Actions** → **Force Rebuild and Deploy**
2. Wait for rebuild to complete
3. Test again

### Issue 3: Routes Not Found

**Cause:** Route cache is stale.

**Solution:**
```bash
# In app console
php artisan route:clear
php artisan route:cache
php artisan route:list | grep admin  # Verify routes exist
```

### Issue 4: "Target class does not exist" Error

**Cause:** Composer autoload needs refresh.

**Solution:**
```bash
composer dump-autoload --optimize
php artisan package:discover
php artisan filament:optimize
```

## Verification Checklist

After deployment, verify:

- [ ] DigitalOcean deployment completed successfully
- [ ] No errors in DigitalOcean build logs
- [ ] Ran `php artisan optimize:clear` in console
- [ ] Ran `php artisan config:cache` and `php artisan route:cache`
- [ ] `/admin` returns 200 or 302 (not 404)
- [ ] `/customer` is accessible
- [ ] Can login to admin panel
- [ ] No nginx 404 pages showing

## Quick Reference

### Scripts Available

| Script | Purpose |
|--------|---------|
| `deploy-fix.sh` | Deploy the fix automatically |
| `test-deployment.sh` | Test if admin/customer panels work |
| `fix-404.sh` | Comprehensive troubleshooting + diagnosis |

### Key Commands

```bash
# Clear all caches
php artisan optimize:clear

# Recache for production
php artisan config:cache
php artisan route:cache
php artisan filament:optimize

# List admin routes (verify they exist)
php artisan route:list | grep admin

# Check Filament panels
php artisan filament:list

# View app info
php artisan about
```

## Technical Details

### Why This Works

1. **Separate Paths:** Admin at `/admin`, customer at `/customer` - no overlap
2. **Filament Routing:** Each panel manages its own route namespace
3. **Clear Separation:** No ambiguity for Laravel's router

### Panel Configuration

```php
// Admin Panel (AdminPanelProvider.php)
->id('admin')
->path('admin')  // Routes: /admin, /admin/login, /admin/dashboard, etc.

// Customer Panel (CustomerPanelProvider.php)
->id('customer')
->path('customer')  // Routes: /customer, /customer/login, /customer/register, etc.
```

## Need More Help?

1. **Check logs:**
   ```bash
   # In DigitalOcean console
   tail -f storage/logs/laravel.log
   ```

2. **View full troubleshooting guide:**
   - See `404-troubleshooting-guide.md`
   - See `DEPLOYMENT-NOTES.md`

3. **Test URLs manually:**
   ```bash
   curl -I https://aureus.abcotronics.co.za/admin
   curl -I https://aureus.abcotronics.co.za/customer
   ```

## Summary

✅ **Fixed:** CustomerPanel path conflict  
✅ **Admin Panel:** Now at `/admin`  
✅ **Customer Portal:** Now at `/customer`  
✅ **Scripts Created:** Automated deployment and testing  

**Next Step:** Run `bash deploy-fix.sh` to deploy these changes!

---

**Created:** October 26, 2025  
**Issue:** 404 errors on /admin after Apache deployment  
**Solution:** Fixed panel path conflict + cache clearing  

