#!/usr/bin/env bash
# This script runs AFTER deployment but BEFORE the web server starts
# It overrides the default nginx location block with Laravel routing support

echo "🔧 Applying custom nginx configuration override..."

# Override the default_include.conf with Laravel-compatible routing
cat > /app/vendor/heroku/heroku-buildpack-php/conf/nginx/default_include.conf << 'EOF'
index index.php index.html index.htm;

location / {
    try_files $uri $uri/ /index.php?$query_string;
}

location ~ ^/(composer\.(json|lock|phar)$|Procfile$|\.env|\.git) {
    deny all;
}
EOF

echo "✅ Custom nginx configuration applied successfully"

