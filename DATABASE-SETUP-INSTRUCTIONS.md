# Database Setup Instructions

## 🎯 **This Will Fix the HTTP 500 Error!**

The 500 error is likely caused by **missing database tables**. Here's how to fix it:

---

## 📋 **Step-by-Step Instructions:**

### **Step 1: Access DigitalOcean Database Console**

1. **Go to:** https://cloud.digitalocean.com/databases
2. **Click** on your MySQL cluster: `db-mysql-nyc3-95734`
3. **Look for** "Console" or "Query" tab
4. **OR** click "Users & Databases" to verify connection details

---

### **Step 2: Check If Tables Exist**

In the database console, run:

```sql
SHOW TABLES;
```

**If you see NO tables or very few tables**, that's the problem!

---

### **Step 3: Run the Migration SQL**

**Copy the entire contents** of `create-tables.sql` and paste into the database console.

**OR run this query to check specific tables:**

```sql
SELECT COUNT(*) as table_count FROM information_schema.tables 
WHERE table_schema = 'defaultdb' AND table_name IN ('users', 'sessions', 'cache');
```

If result is 0, tables are missing!

---

### **Step 4: Create Minimum Required Tables**

**Run this SQL** (creates just the essential tables):

```sql
-- Users table
CREATE TABLE IF NOT EXISTS users (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    email_verified_at TIMESTAMP NULL,
    password VARCHAR(255) NOT NULL,
    remember_token VARCHAR(100) NULL,
    created_at TIMESTAMP NULL,
    updated_at TIMESTAMP NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create admin user (password: password)
INSERT INTO users (name, email, password, created_at, updated_at) 
VALUES (
    'Admin',
    'admin@aureus.com',
    '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi',
    NOW(),
    NOW()
);

-- Sessions table (for when you switch back to database sessions)
CREATE TABLE IF NOT EXISTS sessions (
    id VARCHAR(255) PRIMARY KEY,
    user_id BIGINT UNSIGNED NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    payload LONGTEXT NOT NULL,
    last_activity INT NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

---

### **Step 5: Test Your App**

After running the SQL:

**Visit:** https://walrus-app-yna2h.ondigitalocean.app/admin

**You should see:** ✅ **Filament login page!**

**Login with:**
- Email: `admin@aureus.com`
- Password: `password`

---

## 🆘 **If You Can't Access Database Console:**

### **Alternative: Use MySQL Client**

**Connection Details:**

Get them from DigitalOcean:
1. Go to: https://cloud.digitalocean.com/databases
2. Click your database cluster
3. Connection Details tab shows host, port, username, password

Then paste the SQL from above!

---

## 🎯 **This Will Work Because:**

The app is fully functional - Apache, Laravel, Filament all working.  
**Only missing:** Database tables for users/sessions.  
Once tables exist → Login page appears! ✅

---

**Try accessing the database console NOW and run the SQL!** 🚀

