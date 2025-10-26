# DNS Update Guide - Point Domain to DigitalOcean

## 🎯 Current Situation

**Your Domain:** `aureus.abcotronics.co.za`
**Currently Points To:** LiteSpeed server (41.222.32.15) ❌
**Needs To Point To:** DigitalOcean app ✅

**DigitalOcean App URL:** `walrus-app-yna2h.ondigitalocean.app`

---

## 📋 DNS Update Instructions

### **Option 1: CNAME Record (Recommended)**

Go to your DNS provider (where you manage `abcotronics.co.za`) and update:

```
Type:   CNAME
Name:   aureus
Target: walrus-app-yna2h.ondigitalocean.app
TTL:    3600 (or Auto)
```

**Remove/Replace the existing:**
- A record pointing to `41.222.32.15`
- Or any other CNAME

---

### **Option 2: A Record (Alternative)**

If CNAME doesn't work, use these IP addresses:

```
Type:   A
Name:   aureus
Value:  162.159.140.98  (or 172.66.0.96)
TTL:    3600
```

**Note:** DigitalOcean uses Cloudflare CDN, so IPs may vary.

---

## 🔍 Where to Update DNS

### **Find Your DNS Provider:**

Your domain `abcotronics.co.za` is managed somewhere. Common options:

1. **Domain Registrar** (where you bought the domain)
   - Namecheap
   - GoDaddy
   - Domain.com
   - etc.

2. **DNS Service Provider**
   - Cloudflare
   - DNS Made Easy
   - Route 53 (AWS)
   - etc.

3. **Hosting Provider** (if using shared hosting)
   - cPanel
   - Plesk
   - etc.

---

## 📝 Step-by-Step (Generic)

### **1. Login to DNS Provider**

### **2. Find DNS Management**
Look for:
- "DNS Management"
- "DNS Records"  
- "Zone File"
- "Advanced DNS"

### **3. Locate `aureus` Subdomain**
Find the record for `aureus.abcotronics.co.za`

### **4. Update the Record**

**Delete:**
- Old A record → `41.222.32.15`

**Add:**
- CNAME → `walrus-app-yna2h.ondigitalocean.app`

### **5. Save Changes**

---

## ⏰ DNS Propagation Time

- **Minimum:** 5-10 minutes
- **Typical:** 15-30 minutes
- **Maximum:** Up to 48 hours (rare)

---

## 🧪 Test DNS Update

### **Check if DNS has updated:**

```bash
# From your Mac terminal:
dig aureus.abcotronics.co.za

# Should show:
# aureus.abcotronics.co.za. CNAME walrus-app-yna2h.ondigitalocean.app
```

### **Or use online tools:**
- https://www.whatsmydns.net
- Search for: `aureus.abcotronics.co.za`
- Type: CNAME or A

### **Test the URL:**
Once DNS propagates:
```
https://aureus.abcotronics.co.za/
```

Should show your Laravel app (might still be 404 for /admin, but it's YOUR app!)

---

## ✅ After DNS Update

Once `aureus.abcotronics.co.za` points to DigitalOcean, we need to:

1. **Update APP_URL** in DigitalOcean environment variables:
   ```
   APP_URL=https://aureus.abcotronics.co.za
   ```

2. **Run optimization commands** in console:
   ```bash
   php artisan optimize:clear
   php artisan route:cache
   php artisan config:cache
   php artisan filament:optimize
   ```

3. **Test:**
   ```
   https://aureus.abcotronics.co.za/admin
   ```
   Should show Filament login! 🎉

---

## 🆘 Common DNS Providers - Quick Links

### **Cloudflare:**
1. Login: https://dash.cloudflare.com
2. Select domain: `abcotronics.co.za`
3. Go to: **DNS** tab
4. Find: `aureus` record
5. Edit: Change target to CNAME → `walrus-app-yna2h.ondigitalocean.app`

### **Namecheap:**
1. Login: https://namecheap.com
2. Domain List → Manage `abcotronics.co.za`
3. Advanced DNS tab
4. Find `aureus` record
5. Edit: Type CNAME, Value: `walrus-app-yna2h.ondigitalocean.app`

### **GoDaddy:**
1. Login: https://godaddy.com
2. My Products → DNS
3. Select `abcotronics.co.za`
4. Find `aureus` record
5. Edit: Type CNAME, Points to: `walrus-app-yna2h.ondigitalocean.app`

### **cPanel:**
1. Login to cPanel
2. Find "Zone Editor"
3. Select `abcotronics.co.za`
4. Find `aureus` A record
5. Delete it, Add CNAME: `walrus-app-yna2h.ondigitalocean.app`

---

## 📊 Before & After

### **Before (Current):**
```
aureus.abcotronics.co.za
    ↓ (DNS)
41.222.32.15 (LiteSpeed)
    ↓
404 - No app deployed
```

### **After (Target):**
```
aureus.abcotronics.co.za
    ↓ (DNS)
walrus-app-yna2h.ondigitalocean.app
    ↓
DigitalOcean App (Apache + Laravel)
    ↓
Your AureusERP! ✅
```

---

## 💡 Need Help?

**Can't find your DNS provider?**
Run this command:
```bash
whois abcotronics.co.za | grep -i "name server"
```

This shows where your DNS is hosted.

---

**Next Step:** Go to your DNS provider NOW and make the update!

