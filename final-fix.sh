#!/bin/bash
# COMPREHENSIVE FIX - Run this on Digital Ocean to get the app working

set -e
cd /workspace

echo "========================================="
echo "AUREUSERP DIGITAL OCEAN FIX"
echo "========================================="

# Step 1: Create all database tables
echo "1️⃣  Creating database tables..."
php << 'DBSETUP'
<?php
try {
    $pdo = new PDO(
        "mysql:host=".getenv('DB_HOST').";port=".getenv('DB_PORT').";dbname=".getenv('DB_DATABASE'),
        getenv('DB_USERNAME'),
        getenv('DB_PASSWORD')
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // Core tables
    $pdo->exec("CREATE TABLE IF NOT EXISTS migrations (id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY, migration VARCHAR(255), batch INT)");
    $pdo->exec("CREATE TABLE IF NOT EXISTS settings (id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, `group` VARCHAR(255), name VARCHAR(255), locked TINYINT(1) DEFAULT 0, payload JSON, created_at TIMESTAMP NULL, updated_at TIMESTAMP NULL, UNIQUE KEY(`group`, name))");
    $pdo->exec("CREATE TABLE IF NOT EXISTS cache (`key` VARCHAR(255) PRIMARY KEY, value MEDIUMTEXT, expiration INT)");
    $pdo->exec("CREATE TABLE IF NOT EXISTS cache_locks (`key` VARCHAR(255) PRIMARY KEY, owner VARCHAR(255), expiration INT)");
    $pdo->exec("CREATE TABLE IF NOT EXISTS users (id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255), email VARCHAR(255) UNIQUE, email_verified_at TIMESTAMP NULL, password VARCHAR(255), remember_token VARCHAR(100), created_at TIMESTAMP NULL, updated_at TIMESTAMP NULL)");
    $pdo->exec("CREATE TABLE IF NOT EXISTS password_reset_tokens (email VARCHAR(255) PRIMARY KEY, token VARCHAR(255), created_at TIMESTAMP NULL)");
    $pdo->exec("CREATE TABLE IF NOT EXISTS sessions (id VARCHAR(255) PRIMARY KEY, user_id BIGINT UNSIGNED NULL, ip_address VARCHAR(45), user_agent TEXT, payload LONGTEXT, last_activity INT, INDEX sessions_user_id_index (user_id), INDEX sessions_last_activity_index (last_activity))");
    $pdo->exec("CREATE TABLE IF NOT EXISTS jobs (id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, queue VARCHAR(255), payload LONGTEXT, attempts TINYINT UNSIGNED, reserved_at INT UNSIGNED NULL, available_at INT UNSIGNED, created_at INT UNSIGNED, INDEX jobs_queue_index(queue))");
    $pdo->exec("CREATE TABLE IF NOT EXISTS job_batches (id VARCHAR(255) PRIMARY KEY, name VARCHAR(255), total_jobs INT, pending_jobs INT, failed_jobs INT, failed_job_ids LONGTEXT, options MEDIUMTEXT, cancelled_at INT, created_at INT, finished_at INT)");
    $pdo->exec("CREATE TABLE IF NOT EXISTS failed_jobs (id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, uuid VARCHAR(255) UNIQUE, connection TEXT, queue TEXT, payload LONGTEXT, exception LONGTEXT, failed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP)");
    
    // Permission tables
    $pdo->exec("CREATE TABLE IF NOT EXISTS permissions (id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255), guard_name VARCHAR(255), created_at TIMESTAMP NULL, updated_at TIMESTAMP NULL, UNIQUE KEY permissions_name_guard_name_unique(name, guard_name))");
    $pdo->exec("CREATE TABLE IF NOT EXISTS roles (id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255), guard_name VARCHAR(255), created_at TIMESTAMP NULL, updated_at TIMESTAMP NULL, UNIQUE KEY roles_name_guard_name_unique(name, guard_name))");
    $pdo->exec("CREATE TABLE IF NOT EXISTS model_has_permissions (permission_id BIGINT UNSIGNED, model_type VARCHAR(255), model_id BIGINT UNSIGNED, PRIMARY KEY(permission_id, model_id, model_type))");
    $pdo->exec("CREATE TABLE IF NOT EXISTS model_has_roles (role_id BIGINT UNSIGNED, model_type VARCHAR(255), model_id BIGINT UNSIGNED, PRIMARY KEY(role_id, model_id, model_type))");
    $pdo->exec("CREATE TABLE IF NOT EXISTS role_has_permissions (permission_id BIGINT UNSIGNED, role_id BIGINT UNSIGNED, PRIMARY KEY(permission_id, role_id))");
    
    // Plugin table
    $pdo->exec("CREATE TABLE IF NOT EXISTS plugins (id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY, name VARCHAR(255) UNIQUE, is_installed TINYINT(1) DEFAULT 0, created_at TIMESTAMP NULL, updated_at TIMESTAMP NULL)");
    
    echo "✅ All tables created successfully!\n";
} catch (Exception $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}
DBSETUP

# Step 2: Create package manifest
echo "2️⃣  Creating package manifest..."
mkdir -p bootstrap/cache
cat > bootstrap/cache/packages.php << 'PKGPHP'
<?php return array('livewire/livewire'=>array('providers'=>array('Livewire\\LivewireServiceProvider'),'aliases'=>array('Livewire'=>'Livewire\\Livewire')),'filament/filament'=>array('providers'=>array('Filament\\FilamentServiceProvider')),'bezhansalleh/filament-shield'=>array('providers'=>array('BezhanSalleh\\FilamentShield\\FilamentShieldServiceProvider')),'spatie/laravel-settings'=>array('providers'=>array('Spatie\\LaravelSettings\\LaravelSettingsServiceProvider')),'filament/spatie-laravel-settings-plugin'=>array('providers'=>array('Filament\\SpatieLaravelSettingsPlugin\\SpatieLaravelSettingsPluginServiceProvider')));
PKGPHP

echo "✅ Package manifest created!"

# Step 3: Clear all caches
echo "3️⃣  Clearing caches..."
rm -rf bootstrap/cache/config.php
rm -rf bootstrap/cache/routes-*.php
rm -rf bootstrap/cache/services.php
rm -rf storage/framework/cache/data/*
rm -rf storage/framework/views/*
echo "✅ Caches cleared!"

# Step 4: Test if app works
echo "4️⃣  Testing application..."
curl -s http://localhost:8080/index.php | head -1

echo ""
echo "========================================="
echo "✅ SETUP COMPLETE!"
echo "========================================="
echo "Now run: kill 1"
echo "Then reconnect SSH and refresh your browser!"

