#!/bin/bash
# Install DigitalOcean CLI (doctl)

echo "🔧 Installing DigitalOcean CLI (doctl)..."
echo ""

# Create temp directory
cd /tmp

# Download latest doctl for macOS (Apple Silicon)
echo "📥 Downloading doctl..."
curl -sL https://github.com/digitalocean/doctl/releases/download/v1.109.0/doctl-1.109.0-darwin-arm64.tar.gz -o doctl.tar.gz

# Extract
echo "📦 Extracting..."
tar xf doctl.tar.gz

# Move to local bin
echo "📂 Installing to /usr/local/bin..."
sudo mv doctl /usr/local/bin/

# Make executable
sudo chmod +x /usr/local/bin/doctl

# Cleanup
rm doctl.tar.gz

echo ""
echo "✅ doctl installed successfully!"
echo ""
echo "📋 Next step: Authenticate with DigitalOcean"
echo ""
echo "1. Get your API token:"
echo "   - Go to: https://cloud.digitalocean.com/account/api/tokens"
echo "   - Click 'Generate New Token'"
echo "   - Name: 'doctl-cli' or similar"
echo "   - Permissions: Read + Write"
echo "   - Copy the token (you'll only see it once!)"
echo ""
echo "2. Then run:"
echo "   doctl auth init"
echo ""
echo "3. Paste your token when prompted"
echo ""
echo "4. Test it works:"
echo "   doctl apps list"
echo ""

