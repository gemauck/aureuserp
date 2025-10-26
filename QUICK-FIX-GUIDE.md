# Quick Fix Guide - 404 Issues

## 🔍 What's Wrong?

Your site shows **LiteSpeed 404 errors** on ALL routes. This means the application isn't deployed properly.

## ⚡ Quick Diagnosis

Run this script:
```bash
bash diagnose-deployment.sh
```

## 🎯 Most Likely Issues & Fixes

### Issue #1: Wrong Document Root (MOST COMMON)

**Problem:** Your web server is pointing to the wrong directory.

**Check:** Your document root setting in your hosting control panel.

**Should be:** `/path/to/aureuserp/public` (with `/public` at the end)  
**NOT:** `/path/to/aureuserp` (without `/public`)

**Fix in cPanel/Plesk:**
1. Go to domain settings
2. Find "Document Root" or "Root Directory"
3. Change from `/aureuserp` to `/aureuserp/public`
4. Save and wait 1-2 minutes

**Fix in VPS with LiteSpeed:**
1. Edit your virtual host config
2. Change `DocumentRoot` to include `/public`
3. Restart LiteSpeed: `systemctl restart lsws`

### Issue #2: Deployment Failed

**Problem:** The application didn't deploy successfully.

**Check:** Look at your hosting dashboard for deployment status.

**Fix:**
1. Check for errors in deployment/build logs
2. Ensure `composer install` ran successfully
3. Check for missing PHP extensions
4. Redeploy the application

### Issue #3: .htaccess Not Working

**Problem:** LiteSpeed isn't reading `.htaccess` file in `public/` directory.

**Check:** 
```bash
ls -la public/.htaccess
cat public/.htaccess
```

**Fix in LiteSpeed:**
1. Enable `.htaccess` support in virtual host:
   ```apache
   <Directory /path/to/aureuserp/public>
       AllowOverride All
   </Directory>
   ```
2. Restart LiteSpeed

### Issue #4: File Permissions

**Problem:** Web server can't read your files.

**Check:**
```bash
ls -la /path/to/aureuserp/
ls -la /path/to/aureuserp/public/
```

**Fix:**
```bash
# Set correct ownership (replace 'nobody' with your web server user)
chown -R nobody:nobody /path/to/aureuserp

# Set correct permissions
chmod -R 755 /path/to/aureuserp
chmod -R 775 /path/to/aureuserp/storage
chmod -R 775 /path/to/aureuserp/bootstrap/cache
```

Common web server users:
- cPanel: `nobody` or `username`
- Ubuntu/Debian: `www-data`
- RHEL/CentOS: `apache` or `nginx`
- LiteSpeed: `nobody` or `lsadm`

## 🔧 Step-by-Step Fix

### For cPanel/Plesk Users:

1. **Log into cPanel/Plesk**
2. **Go to your domain settings** (Domains → your domain)
3. **Check Document Root:**
   - If it says `/home/username/aureuserp`, change to `/home/username/aureuserp/public`
   - If it says `/var/www/aureuserp`, change to `/var/www/aureuserp/public`
4. **Save changes**
5. **Wait 1-2 minutes**
6. **Test:** `bash test-deployment.sh`

### For VPS/Cloud Users:

1. **Find your web server config file:**
   - LiteSpeed: `/usr/local/lsws/conf/vhosts/*/vhost.conf`
   - Apache: `/etc/apache2/sites-available/*.conf` or `/etc/httpd/conf.d/*.conf`
   - nginx: `/etc/nginx/sites-available/*` or `/etc/nginx/conf.d/*.conf`

2. **Edit the config file:**
   ```apache
   # LiteSpeed/Apache
   DocumentRoot /path/to/aureuserp/public
   <Directory /path/to/aureuserp/public>
       AllowOverride All
       Require all granted
   </Directory>
   ```

   ```nginx
   # nginx
   root /path/to/aureuserp/public;
   location / {
       try_files $uri $uri/ /index.php?$query_string;
   }
   ```

3. **Test configuration:**
   ```bash
   # LiteSpeed
   /usr/local/lsws/bin/lswsctrl configtest
   
   # Apache
   apachectl configtest
   
   # nginx
   nginx -t
   ```

4. **Restart web server:**
   ```bash
   # LiteSpeed
   systemctl restart lsws
   
   # Apache
   systemctl restart apache2  # or httpd
   
   # nginx
   systemctl restart nginx
   ```

5. **Test:** `bash test-deployment.sh`

### For DigitalOcean App Platform:

Your Procfile says Apache, but the server is LiteSpeed. This is a mismatch.

**Option A: Verify you're actually on DigitalOcean App Platform**
- If yes: The platform should handle Apache automatically
- If no: Remove Procfile, it's not needed

**Option B: Reconfigure the app:**
1. Go to app dashboard on DigitalOcean
2. Check "Build & Deployment" settings
3. Ensure run command is correct
4. Force rebuild and deploy

## ✅ After Fixing Deployment

Once the site is working, deploy the routing fixes:

```bash
# Deploy the panel path fixes
bash deploy-fix.sh

# Wait for deployment to complete

# Clear caches (in your app console)
php artisan optimize:clear
php artisan config:cache
php artisan route:cache

# Test again
bash test-deployment.sh
```

## 🆘 Still Not Working?

Provide this information:
1. **Hosting type:** cPanel / Plesk / VPS / DigitalOcean / Other?
2. **Document root setting:** What does it say in your control panel?
3. **File permissions:** Output of `ls -la /path/to/aureuserp/`
4. **Can you run:** `php artisan about` in console/SSH?
5. **Error logs:** Any errors in `/path/to/aureuserp/storage/logs/laravel.log`?

## 📁 Files I Created

- `diagnose-deployment.sh` - Full diagnostic check
- `URGENT-FIX-NEEDED.md` - Detailed explanation of the issue
- `404-FIX-README.md` - About the routing fixes (for later)
- `deploy-fix.sh` - Deploy routing fixes (after site works)
- `test-deployment.sh` - Test if site is working
- `fix-404.sh` - Additional troubleshooting

## 🎯 Most Likely Solution

**90% chance it's this:** Your document root doesn't include `/public`

**Fix:** Add `/public` to the end of your document root path in your hosting control panel.

---

**TL;DR:** Check your document root in hosting settings. It needs `/public` at the end.

