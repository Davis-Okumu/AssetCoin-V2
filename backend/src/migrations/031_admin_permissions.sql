-- =========================================================
-- 031 ADMIN PERMISSIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS `admin_permissions` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,

  `name` VARCHAR(150) NOT NULL,
  `code` VARCHAR(150) NOT NULL UNIQUE,

  `module` VARCHAR(100) NOT NULL,
  `action` VARCHAR(100) NOT NULL,

  `description` VARCHAR(255) DEFAULT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_admin_permissions_module` (`module`),
  KEY `idx_admin_permissions_action` (`action`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================================================
-- DASHBOARD
-- =========================================================

INSERT INTO `admin_permissions`
  (`name`, `code`, `module`, `action`, `description`)
VALUES
  ('View Dashboard', 'dashboard.view', 'dashboard', 'view',
   'View the administration dashboard.'),

-- =========================================================
-- USERS
-- =========================================================

  ('View Users', 'users.view', 'users', 'view',
   'View customer accounts.'),

  ('Create Users', 'users.create', 'users', 'create',
   'Create customer accounts.'),

  ('Update Users', 'users.update', 'users', 'update',
   'Update customer account information.'),

  ('Suspend Users', 'users.suspend', 'users', 'suspend',
   'Suspend customer accounts.'),

  ('Deactivate Users', 'users.deactivate', 'users', 'deactivate',
   'Deactivate customer accounts.'),

-- =========================================================
-- KYC
-- =========================================================

  ('View KYC', 'kyc.view', 'kyc', 'view',
   'View KYC submissions.'),

  ('Review KYC', 'kyc.review', 'kyc', 'review',
   'Review KYC submissions.'),

  ('Approve KYC', 'kyc.approve', 'kyc', 'approve',
   'Approve KYC submissions.'),

  ('Reject KYC', 'kyc.reject', 'kyc', 'reject',
   'Reject KYC submissions.'),

-- =========================================================
-- ASSETS
-- =========================================================

  ('View Assets', 'assets.view', 'assets', 'view',
   'View customer assets.'),

  ('Review Assets', 'assets.review', 'assets', 'review',
   'Review submitted assets.'),

  ('Approve Assets', 'assets.approve', 'assets', 'approve',
   'Approve assets for tokenization.'),

  ('Reject Assets', 'assets.reject', 'assets', 'reject',
   'Reject asset submissions.'),

  ('Assign Assets', 'assets.assign', 'assets', 'assign',
   'Assign assets to staff members.'),

  ('Suspend Assets', 'assets.suspend', 'assets', 'suspend',
   'Suspend tokenized or approved assets.'),

-- =========================================================
-- TOKENIZATION
-- =========================================================

  ('View Tokenization', 'tokenization.view', 'tokenization', 'view',
   'View tokenization records.'),

  ('Create Tokenization', 'tokenization.create', 'tokenization', 'create',
   'Create tokenization proposals.'),

  ('Approve Tokenization', 'tokenization.approve', 'tokenization', 'approve',
   'Approve tokenization proposals.'),

  ('Reject Tokenization', 'tokenization.reject', 'tokenization', 'reject',
   'Reject tokenization proposals.'),

  ('Suspend Tokenization', 'tokenization.suspend', 'tokenization', 'suspend',
   'Suspend tokenized assets.'),

-- =========================================================
-- TRADING
-- =========================================================

  ('View Trading', 'trading.view', 'trading', 'view',
   'View marketplace activity.'),

  ('Manage Trading', 'trading.manage', 'trading', 'manage',
   'Manage marketplace operations.'),

  ('Suspend Listings', 'trading.suspend_listings', 'trading', 'suspend_listings',
   'Suspend marketplace listings.'),

  ('Manage Orders', 'trading.manage_orders', 'trading', 'manage_orders',
   'Manage marketplace orders.'),

-- =========================================================
-- FINANCE
-- =========================================================

  ('View Finance', 'finance.view', 'finance', 'view',
   'View financial information.'),

  ('Manage Finance', 'finance.manage', 'finance', 'manage',
   'Manage financial operations.'),

  ('Approve Finance Actions', 'finance.approve', 'finance', 'approve',
   'Approve sensitive financial operations.'),

  ('View Wallets', 'wallets.view', 'wallets', 'view',
   'View customer wallets.'),

  ('Manage Wallets', 'wallets.manage', 'wallets', 'manage',
   'Manage authorized wallet operations.'),

-- =========================================================
-- LEDGER
-- =========================================================

  ('View Ledger', 'ledger.view', 'ledger', 'view',
   'View centralized ledger entries.'),

  ('Export Ledger', 'ledger.export', 'ledger', 'export',
   'Export ledger records.'),

-- =========================================================
-- SUPPORT
-- =========================================================

  ('View Support Tickets', 'support.view', 'support', 'view',
   'View customer support tickets.'),

  ('Manage Support Tickets', 'support.manage', 'support', 'manage',
   'Manage customer support tickets.'),

  ('Assign Support Tickets', 'support.assign', 'support', 'assign',
   'Assign support tickets.'),

-- =========================================================
-- NOTIFICATIONS
-- =========================================================

  ('View Notifications', 'notifications.view', 'notifications', 'view',
   'View administrative notifications.'),

  ('Create Notifications', 'notifications.create', 'notifications', 'create',
   'Create notifications.'),

  ('Send Notifications', 'notifications.send', 'notifications', 'send',
   'Send notifications to customers.'),

-- =========================================================
-- CONTENT
-- =========================================================

  ('View Content', 'content.view', 'content', 'view',
   'View announcements and news.'),

  ('Create Content', 'content.create', 'content', 'create',
   'Create announcements and news.'),

  ('Update Content', 'content.update', 'content', 'update',
   'Update announcements and news.'),

  ('Publish Content', 'content.publish', 'content', 'publish',
   'Publish announcements and news.'),

-- =========================================================
-- STAFF
-- =========================================================

  ('View Staff', 'staff.view', 'staff', 'view',
   'View administrative staff.'),

  ('Create Staff', 'staff.create', 'staff', 'create',
   'Create administrative staff accounts.'),

  ('Update Staff', 'staff.update', 'staff', 'update',
   'Update administrative staff.'),

  ('Suspend Staff', 'staff.suspend', 'staff', 'suspend',
   'Suspend administrative staff.'),

  ('Manage Staff Permissions', 'staff.permissions', 'staff', 'permissions',
   'Manage staff roles and permissions.'),

-- =========================================================
-- SETTINGS
-- =========================================================

  ('View Settings', 'settings.view', 'settings', 'view',
   'View administration settings.'),

  ('Update Settings', 'settings.update', 'settings', 'update',
   'Update administration settings.'),

-- =========================================================
-- AUDIT
-- =========================================================

  ('View Audit Logs', 'audit.view', 'audit', 'view',
   'View administrative audit logs.'),

  ('Export Audit Logs', 'audit.export', 'audit', 'export',
   'Export administrative audit logs.')

ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `description` = VALUES(`description`);