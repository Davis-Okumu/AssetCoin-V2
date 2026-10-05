-- =========================================================
-- 037 ADMIN LOGIN ACTIVITY
-- =========================================================

CREATE TABLE IF NOT EXISTS `admin_login_activity` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

  `staffId` INT UNSIGNED DEFAULT NULL,

  `eventType` ENUM(
    'login_success',
    'login_failed',
    'logout',
    'password_changed',
    'password_reset',
    'session_revoked',
    'account_locked',
    'account_unlocked'
  ) NOT NULL,

  `ipAddress` VARCHAR(45) DEFAULT NULL,

  `userAgent` VARCHAR(500) DEFAULT NULL,

  `description` VARCHAR(255) DEFAULT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_admin_login_staffId` (`staffId`),
  KEY `idx_admin_login_eventType` (`eventType`),
  KEY `idx_admin_login_createdAt` (`createdAt`),

  CONSTRAINT `fk_admin_login_staff`
    FOREIGN KEY (`staffId`)
    REFERENCES `admin_staff` (`id`)
    ON DELETE SET NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;