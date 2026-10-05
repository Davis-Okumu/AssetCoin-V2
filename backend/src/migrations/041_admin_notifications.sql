-- =========================================================
-- 041 ADMIN NOTIFICATIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS `admin_notifications` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

  `staffId` INT UNSIGNED DEFAULT NULL,

  `type` ENUM(
    'system',
    'security',
    'workflow',
    'approval',
    'asset',
    'kyc',
    'tokenization',
    'trading',
    'finance',
    'support'
  ) NOT NULL DEFAULT 'system',

  `title` VARCHAR(200) NOT NULL,

  `message` TEXT NOT NULL,

  `referenceType` VARCHAR(100) DEFAULT NULL,

  `referenceId` BIGINT UNSIGNED DEFAULT NULL,

  `status` ENUM(
    'new',
    'read',
    'archived'
  ) NOT NULL DEFAULT 'new',

  `readAt` DATETIME DEFAULT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_admin_notifications_staffId`
    (`staffId`),

  KEY `idx_admin_notifications_type`
    (`type`),

  KEY `idx_admin_notifications_status`
    (`status`),

  KEY `idx_admin_notifications_reference`
    (`referenceType`, `referenceId`),

  KEY `idx_admin_notifications_createdAt`
    (`createdAt`),

  CONSTRAINT `fk_admin_notifications_staff`
    FOREIGN KEY (`staffId`)
    REFERENCES `admin_staff` (`id`)
    ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;