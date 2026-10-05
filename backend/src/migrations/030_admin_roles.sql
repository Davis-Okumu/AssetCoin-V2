-- =========================================================
-- 030 ADMIN ROLES
-- =========================================================

CREATE TABLE IF NOT EXISTS `admin_roles` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,

  `name` VARCHAR(100) NOT NULL,
  `code` VARCHAR(100) NOT NULL UNIQUE,
  `description` VARCHAR(255) DEFAULT NULL,

  `isSystemRole` BOOLEAN NOT NULL DEFAULT TRUE,
  `isActive` BOOLEAN NOT NULL DEFAULT TRUE,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_admin_roles_active` (`isActive`),
  KEY `idx_admin_roles_code` (`code`)

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================================================
-- DEFAULT ADMIN ROLES
-- =========================================================

INSERT INTO `admin_roles`
  (`name`, `code`, `description`, `isSystemRole`, `isActive`)
VALUES
  (
    'Super Administrator',
    'super_admin',
    'Full access to all administrative functions.',
    TRUE,
    TRUE
  ),
  (
    'Asset Officer',
    'asset_officer',
    'Reviews and manages customer asset submissions.',
    TRUE,
    TRUE
  ),
  (
    'KYC Officer',
    'kyc_officer',
    'Reviews and manages customer identity verification.',
    TRUE,
    TRUE
  ),
  (
    'Tokenization Officer',
    'tokenization_officer',
    'Manages approved asset tokenization workflows.',
    TRUE,
    TRUE
  ),
  (
    'Finance Officer',
    'finance_officer',
    'Manages wallets, payments and financial operations.',
    TRUE,
    TRUE
  ),
  (
    'Trading Officer',
    'trading_officer',
    'Monitors marketplace and trading operations.',
    TRUE,
    TRUE
  ),
  (
    'Support Officer',
    'support_officer',
    'Manages customer support operations.',
    TRUE,
    TRUE
  ),
  (
    'Auditor',
    'auditor',
    'Read-only access to audit and operational records.',
    TRUE,
    TRUE
  )
ON DUPLICATE KEY UPDATE
  `name` = VALUES(`name`),
  `description` = VALUES(`description`);