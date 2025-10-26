# Generate New DigitalOcean API Token

## ❌ Previous Token Issue

The token provided couldn't authenticate. This can happen if:
- Token was copied incorrectly
- Token doesn't have proper permissions
- Token was already used/revoked

---

## ✅ Generate a Fresh Token (2 Minutes)

### Step 1: Open Token Page
Go to: https://cloud.digitalocean.com/account/api/tokens

### Step 2: Generate New Token

Click **"Generate New Token"** and configure:

**Token Configuration:**
```
Token Name: doctl-aureuserp
Expiration: 90 days (or No expiry)
Scopes: 
  ✅ Read
  ✅ Write
```

### Step 3: Important!
- Click **"Generate Token"**
- **COPY THE ENTIRE TOKEN** immediately
- Token starts with: `dop_v1_`
- It's a long string (about 64 characters)
- You'll only see it ONCE!

### Step 4: Authenticate

Run this command:
```bash
doctl auth init
```

Then **paste the token** when prompted and press Enter.

---

## 🧪 Alternative: Manual Authentication

If the interactive method doesn't work, save your token to a file:

```bash
# Save token to file (replace YOUR_TOKEN with actual token)
echo "YOUR_TOKEN" > ~/.doctl-token

# Authenticate using the file
doctl auth init -t $(cat ~/.doctl-token)

# Remove the token file for security
rm ~/.doctl-token
```

---

## ✅ Verify Authentication

After authenticating, test it works:

```bash
# Should list your apps
doctl apps list

# Should show your specific app
doctl apps list | grep walrus
```

If you see your app listed, authentication worked! ✅

---

## 🔐 Security Note

**Never share your API token!** It gives full access to your DigitalOcean account.

- ✅ DO: Keep it private
- ✅ DO: Use it only in secure terminals
- ❌ DON'T: Share it in chat/email
- ❌ DON'T: Commit it to git

---

**Next Step:** Go to https://cloud.digitalocean.com/account/api/tokens and generate a new token!

