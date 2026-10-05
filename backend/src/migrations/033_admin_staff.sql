-- =========================================================
-- 032 ADMIN ROLE PERMISSIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS `admin_role_permissions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

  `roleId` INT UNSIGNED NOT NULL,
  `permissionId` INT UNSIGNED NOT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  UNIQUE KEY `uq_admin_role_permission`
    (`roleId`, `permissionId`),

  KEY `idx_admin_role_permissions_role`
    (`roleId`),

  KEY `idx_admin_role_permissions_permission`
    (`permissionId`),

  CONSTRAINT `fk_admin_role_permissions_role`
    FOREIGN KEY (`roleId`)
    REFERENCES `admin_roles` (`id`)
    ON DELETE CASCADE,

  CONSTRAINT `fk_admin_role_permissions_permission`
    FOREIGN KEY (`permissionId`)
    REFERENCES `admin_permissions` (`id`)
    ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================================================
-- SUPER ADMINISTRATOR
-- =========================================================

INSERT INTO `admin_role_permissions`
  (`roleId`, `permissionId`)
SELECT
  r.id,
  p.id
FROM `admin_roles` r
CROSS JOIN `admin_permissions` p
WHERE r.code = 'super_admin'
ON DUPLICATE KEY UPDATE
  `roleId` = VALUES(`roleId`);


-- =========================================================
-- ASSET OFFICER
-- =========================================================

INSERT INTO `admin_role_permissions`
  (`roleId`, `permissionId`)
SELECT
  r.id,
  p.id
FROM `admin_roles` r
JOIN `admin_permissions` p
WHERE r.code = 'asset_officer'
AND p.code IN (
  'dashboard.view',
  'assets.view',
  'assets.review',
  'assets.approve',
  'assets.reject',
  'assets.assign'
)
ON DUPLICATE KEY UPDATE
  `roleId` = VALUES(`roleId`);


-- =========================================================
-- KYC OFFICER
-- =========================================================

INSERT INTO `admin_role_permissions`
  (`roleId`, `permissionId`)
SELECT
  r.id,
  p.id
FROM `admin_roles` r
JOIN `admin_permissions` p
WHERE r.code = 'kyc_officer'
AND p.code IN (
  'dashboard.view',
  'users.view',
  'kyc.view',
  'kyc.review',
  'kyc.approve',
  'kyc.reject'
)
ON DUPLICATE KEY UPDATE
  `roleId` = VALUES(`roleId`);


-- =========================================================
-- TOKENIZATION OFFICER
-- =========================================================

INSERT INTO `admin_role_permissions`
  (`roleId`, `permissionId`)
SELECT
  r.id,
  p.id
FROM `admin_roles` r
JOIN `admin_permissions` p
WHERE r.code = 'tokenization_officer'
AND p.code IN (
  'dashboard.view',
  'assets.view',
  'tokenization.view',
  'tokenization.create',
  'tokenization.approve',
  'tokenization.reject',
  'tokenization.suspend'
)
ON DUPLICATE KEY UPDATE
  `roleId` = VALUES(`roleId`);


-- =========================================================
-- FINANCE OFFICER
-- =========================================================

INSERT INTO `admin_role_permissions`
  (`roleId`, `permissionId`)
SELECT
  r.id,
  p.id
FROM `admin_roles` r
JOIN `admin_permissions` p
WHERE r.code = 'finance_officer'
AND p.code IN (
  'dashboard.view',
  'finance.view',
  'finance.manage',
  'finance.approve',
  'wallets.view',
  'wallets.manage',
  'ledger.view',
  'ledger.export'
)
ON DUPLICATE KEY UPDATE
  `roleId` = VALUES(`roleId`);


-- =========================================================
-- TRADING OFFICER
-- =========================================================

INSERT INTO `admin_role_permissions`
  (`roleId`, `permissionId`)
SELECT
  r.id,
  p.id
FROM `admin_roles` r
JOIN `admin_permissions` p
WHERE r.code = 'trading_officer'
AND p.code IN (
  'dashboard.view',
  'trading.view',
  'trading.manage',
  'trading.suspend_listings',
  'trading.manage_orders'
)
ON DUPLICATE KEY UPDATE
  `roleId` = VALUES(`roleId`);


-- =========================================================
-- SUPPORT OFFICER
-- =========================================================

INSERT INTO `admin_role_permissions`
  (`roleId`, `permissionId`)
SELECT
  r.id,
  p.id
FROM `admin_roles` r
JOIN `admin_permissions` p
WHERE r.code = 'support_officer'
AND p.code IN (
  'dashboard.view',
  'users.view',
  'support.view',
  'support.manage',
  'support.assign',
  'notifications.view',
  'notifications.create'
)
ON DUPLICATE KEY UPDATE
  `roleId` = VALUES(`roleId`);


-- =========================================================
-- AUDITOR
-- =========================================================

INSERT INTO `admin_role_permissions`
  (`roleId`, `permissionId`)
SELECT
  r.id,
  p.id
FROM `admin_roles` r
JOIN `admin_permissions` p
WHERE r.code = 'auditor'
AND p.code IN (
  'dashboard.view',
  'users.view',
  'kyc.view',
  'assets.view',
  'tokenization.view',
  'trading.view',
  'finance.view',
  'wallets.view',
  'ledger.view',
  'ledger.export',
  'audit.view',
  'audit.export',
  'support.view',
  'notifications.view',
  'content.view'
)
ON DUPLICATE KEY UPDATE
  `roleId` = VALUES(`roleId`);