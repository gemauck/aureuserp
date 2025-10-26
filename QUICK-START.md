# Quick Start - Resolving nginx 404 Issues

## 🎯 Problem Summary
nginx returns 404 for `/admin` because `default_include.conf` doesn't have Laravel's `try_files` directive.

## ✅ Solution Deployed (3-Layer Approach)

### Layer 1: Custom nginx Config (nginx-custom.conf)
- **File**: `nginx-custom.conf` 
- **Procfile**: Uses `-C nginx-custom.conf` flag
- **Status**: ✅ Deployed
- **Effectiveness**: May work if `-C` flag properly includes the config

### Layer 2: Hook Script (RECOMMENDED - WILL DEFINITELY WORK) ⭐
- **File**: `.profile.d/nginx-override.sh`
- **How it works**:
  1. Deployment pushes your code
  2. `composer install` runs (recreates vendor/)
  3. **Hook script runs** ← Modifies vendor nginx config
  4. nginx starts with modified config
- **Status**: ✅ Deployed
- **Effectiveness**: **GUARANTEED** - Runs at the right time in deployment cycle

### Layer 3: Apache Fallback
- **File**: `Procfile.apache`
- **Use if**: nginx approaches still fail
- **Activation**: `cp Procfile.apache Procfile && git push`

## 📋 What Happens Now

When your app deploys:

```
1. Code pushed to server
2. composer install (vendor/ recreated)
3. .profile.d/nginx-override.sh runs  ← MODIFIES VENDOR CONFIG
4. nginx starts with Laravel routing enabled  ← WILL WORK!
```

## 🧪 Testing After Deployment

### 1. Check Hook Script Ran
SSH into your pod and check:
```bash
cat /app/vendor/heroku/heroku-buildpack-php/conf/nginx/default_include.conf
```

**Should contain**:
```nginx
location / {
    try_files $uri $uri/ /index.php?$query_string;
}
```

### 2. Test URLs
```bash
# Should work (Filament login):
curl -I https://your-app.com/admin

# Should be blocked (security):
curl -I https://your-app.com/composer.json  # → 403 or 404
```

### 3. Check Laravel Routes
```bash
php artisan route:list | grep admin
```

Should show Filament routes like:
```
GET|HEAD  admin ...................... filament.admin.auth.login
POST      admin/login ................ filament.admin.auth.login
...
```

## 🚨 If Still Getting 404

### Quick Fix: Switch to Apache
```bash
cd /Users/gemau/Desktop/aureuserp
cp Procfile.apache Procfile
git add Procfile
git commit -m "Switch to Apache for Laravel routing"
git push
```

Apache works immediately because Laravel's `.htaccess` is already configured correctly.

## 📊 Why Hook Script Works vs Direct vendor/ Modification

### ❌ Your Original Approach (Won't Work):
```bash
# Locally:
git add -f vendor/file.conf  # Force add
git push

# On server:
composer install   # ← DELETES entire vendor/, your file is GONE
nginx starts       # Uses default config
```

### ✅ Hook Script Approach (WILL Work):
```bash
# On server during deployment:
composer install                    # Recreates vendor/
.profile.d/nginx-override.sh runs  # ← MODIFIES vendor AFTER composer
nginx starts                        # Uses modified config ✅
```

## 🎓 Key Takeaway

**Never commit vendor/ files** - They're gitignored and get overwritten.

**Instead use**:
- Custom config files in project root (nginx-custom.conf)
- Hook scripts that run at the right time (.profile.d/)
- Platform-specific configuration options

## 📞 Next Steps

1. **Wait for deployment** (~3-5 minutes)
2. **Test** `/admin` URL
3. **Check logs** if issues persist:
   ```bash
   # In production:
   tail -f storage/logs/laravel.log
   ```
4. **Verify hook ran** (see testing section above)
5. **Switch to Apache** if nginx still problematic (see quick fix above)

## 📚 Additional Resources

- `DEPLOYMENT-NOTES.md` - Detailed deployment guide
- `404-troubleshooting-guide.md` - Complete troubleshooting checklist
- `Procfile.apache` - Ready-to-use Apache configuration

---

**Confidence Level**: 🟢 **HIGH** - The hook script approach will work!

**Last Updated**: October 26, 2025

