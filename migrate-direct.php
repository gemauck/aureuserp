<?php
// Direct database migration script - bypasses Laravel
echo "🚀 Starting direct database migration...\n";

$host = getenv('DB_HOST');
$port = getenv('DB_PORT');
$dbname = getenv('DB_DATABASE');
$username = getenv('DB_USERNAME');
$password = getenv('DB_PASSWORD');

try {
    $pdo = new PDO("mysql:host=$host;port=$port;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    echo "✅ Connected to database\n";
    
    // Create migrations table
    echo "📋 Creating migrations table...\n";
    $pdo->exec("CREATE TABLE IF NOT EXISTS migrations (
        id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        migration VARCHAR(255) NOT NULL,
        batch INT NOT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    
    // Create settings table
    echo "⚙️  Creating settings table...\n";
    $pdo->exec("CREATE TABLE IF NOT EXISTS settings (
        id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        `group` VARCHAR(255) NOT NULL,
        name VARCHAR(255) NOT NULL,
        locked TINYINT(1) NOT NULL DEFAULT 0,
        payload JSON NOT NULL,
        created_at TIMESTAMP NULL,
        updated_at TIMESTAMP NULL,
        UNIQUE KEY settings_group_name_unique (`group`, name)
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    
    // Create cache table
    echo "💾 Creating cache table...\n";
    $pdo->exec("CREATE TABLE IF NOT EXISTS cache (
        `key` VARCHAR(255) PRIMARY KEY,
        value MEDIUMTEXT NOT NULL,
        expiration INT NOT NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    
    // Create users table
    echo "👤 Creating users table...\n";
    $pdo->exec("CREATE TABLE IF NOT EXISTS users (
        id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
        name VARCHAR(255) NOT NULL,
        email VARCHAR(255) NOT NULL UNIQUE,
        email_verified_at TIMESTAMP NULL,
        password VARCHAR(255) NOT NULL,
        remember_token VARCHAR(100) NULL,
        created_at TIMESTAMP NULL,
        updated_at TIMESTAMP NULL
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci");
    
    echo "✅ Essential tables created successfully!\n";
    echo "Now run: php artisan migrate --force\n";
    
} catch (PDOException $e) {
    echo "❌ Error: " . $e->getMessage() . "\n";
    exit(1);
}

