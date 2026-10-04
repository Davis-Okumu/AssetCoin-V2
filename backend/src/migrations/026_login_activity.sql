
-- =========================================================
-- 26. Login Activity Table
-- =========================================================

CREATE TABLE IF NOT EXISTS `login_activity` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `userId` INT UNSIGNED DEFAULT NULL,

  `eventType` ENUM(
    'login_success',
    'login_failed',
    'logout',
    'password_changed',
    'password_reset',
    'two_factor_enabled',
    'two_factor_disabled',
    'session_revoked'
  ) NOT NULL,

  `deviceName` VARCHAR(150) DEFAULT NULL,

  `deviceType` ENUM(
    'mobile',
    'desktop',
    'tablet',
    'unknown'
  ) NOT NULL DEFAULT 'unknown',

  `ipAddress` VARCHAR(45) DEFAULT NULL,
  `userAgent` VARCHAR(500) DEFAULT NULL,

  `description` VARCHAR(255) DEFAULT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_login_activity_userId` (`userId`),
  KEY `idx_login_activity_eventType` (`eventType`),
  KEY `idx_login_activity_createdAt` (`createdAt`),

  CONSTRAINT `fk_login_activity_user`
    FOREIGN KEY (`userId`) REFERENCES `users` (`id`)
    ON DELETE SET NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;