# DigitalOcean CLI (doctl) Setup

## ✅ Installation Complete!

doctl is now installed at: `~/bin/doctl`

---

## 🔐 Step 1: Get Your API Token

1. **Open this URL in your browser:**
   ```
   https://cloud.digitalocean.com/account/api/tokens
   ```

2. **Click "Generate New Token"**

3. **Configure the token:**
   - **Token name**: `doctl-cli` (or any name you want)
   - **Expiration**: 90 days (or No expiry)
   - **Scopes**: Select **both**:
     - ✅ Read
     - ✅ Write

4. **Click "Generate Token"**

5. **COPY THE TOKEN IMMEDIATELY!** 
   - ⚠️ You'll only see it once!
   - It looks like: `dop_v1_1234567890abcdef...`

---

## 🔧 Step 2: Authenticate doctl

Run this command in your terminal:

```bash
doctl auth init
```

When prompted:
- **Paste your API token**
- Press Enter

You should see:
```
Validating token... OK
```

---

## ✅ Step 3: Test It Works

Run these commands to verify:

```bash
# List your apps
doctl apps list

# Get details about your app
doctl apps get walrus-app-yna2h

# View recent deployments
doctl apps list-deployments walrus-app-yna2h
```

---

## 🚀 Useful Commands

### Check App Status
```bash
doctl apps list
```

### View App Details
```bash
doctl apps get walrus-app-yna2h
```

### View Logs
```bash
doctl apps logs walrus-app-yna2h --type=run
```

### Force New Deployment
```bash
doctl apps create-deployment walrus-app-yna2h
```

### Get App URL
```bash
doctl apps get walrus-app-yna2h --format URL
```

---

## 📋 Quick Reference

| Command | Description |
|---------|-------------|
| `doctl apps list` | List all your apps |
| `doctl apps get APP_ID` | Get app details |
| `doctl apps logs APP_ID` | View app logs |
| `doctl apps create-deployment APP_ID` | Force redeploy |
| `doctl apps list-deployments APP_ID` | List deployments |

---

## 🆘 Troubleshooting

### "doctl: command not found"
Run:
```bash
export PATH="$HOME/bin:$PATH"
doctl version
```

### "Unable to authenticate"
- Check your token is correct
- Make sure you copied the entire token
- Generate a new token if needed

### "App not found"
Get your app ID from:
```bash
doctl apps list
```

---

**Next Step**: Get your API token from https://cloud.digitalocean.com/account/api/tokens

