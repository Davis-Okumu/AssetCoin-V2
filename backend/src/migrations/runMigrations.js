/**
 * Migration runner
 * Usage: `node src/migrations/runMigrations.js`
 */

import 'dotenv/config';
import fs from 'fs';
import path from 'path';
import mysql from 'mysql2/promise';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Ensure required env variables are set
['DB_HOST', 'DB_USER', 'DB_PASS', 'DB_NAME'].forEach(v => {
  if (!process.env[v]) {
    console.error(`ERROR: ${v} is not set in your .env file`);
    process.exit(1);
  }
});

const run = async () => {
  const conn = await mysql.createConnection({
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 3306,
    user: process.env.DB_USER,
    password: process.env.DB_PASS,
    multipleStatements: true
  });

  // Ensure database exists
  const dbName = process.env.DB_NAME;

  await conn.query(
    `CREATE DATABASE IF NOT EXISTS \`${dbName}\`
     CHARACTER SET utf8mb4
     COLLATE utf8mb4_general_ci`
  );

  await conn.query(`USE \`${dbName}\``);

  // =========================================================
  // Migration files
  // =========================================================
  //
  // Naming convention:
  // 001_users.sql
  // 002_kyc_records.sql
  // 003_assets.sql
  // etc.
  //
  // "create" has intentionally been removed from filenames.
  // =========================================================

  const migrationsDir = __dirname;

  const files = [
    '001_users.sql',
    '002_kyc_records.sql',
    '003_assets.sql',
    '004_asset_photos.sql',
    '005_asset_documents.sql',
    '006_asset_valuations.sql',
    '007_tokens.sql',
    '008_token_holdings.sql',
    '009_wallets.sql',
    '010_wallet_transactions.sql',

    // Trading
    '011_listings.sql',
    '012_orders.sql',
    '013_transactions.sql',
    '014_token_price_history.sql',

    // Ledger & auditing
    '015_ledger_entries.sql',
    '016_audit_logs.sql',

    // Communication
    '017_notifications.sql',
    '018_announcements.sql',
    '019_news.sql',
    // '20_insert_sample.sql',
    '021_password_reset_tokens.sql',
    '022_asset_reviews.sql',
    '023_asset_status_history.sql',
    
    // Security
    "024_user_sessions.sql",
    "025_user_security_settings.sql",
    "026_login_activity.sql",

    // Profile Settings & Support
    '027_user_preferences.sql',
    '028_support_tickets.sql',
    '029_user_notification_preferences'

  ];

  // =========================================================
  // Run migrations in order
  // =========================================================

  for (const f of files) {
    const filePath = path.join(migrationsDir, f);

    if (!fs.existsSync(filePath)) {
      console.warn(`⚠️ Migration file not found: ${f}, skipping.`);
      continue;
    }

    const sql = fs.readFileSync(filePath, 'utf8').trim();

    if (!sql) {
      console.warn(`⚠️ Migration file is empty: ${f}, skipping.`);
      continue;
    }

    console.log(`➡️ Running ${f} ...`);

    try {
      await conn.query(sql);
      console.log(`✅ Completed ${f}`);
    } catch (err) {
      console.error(`❌ Error running ${f}:`, err.message);
      throw err;
    }
  }

  console.log('');
  console.log('🎉 All migrations completed successfully.');

  await conn.end();
};

run().catch(err => {
  console.error('');
  console.error('❌ Migration failed:', err.message);
  process.exit(1);
});

export default run;