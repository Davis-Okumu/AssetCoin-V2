-- =========================================================
-- 035 ADMIN SESSIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS `admin_sessions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

  `staffId` INT UNSIGNED NOT NULL,

  `sessionTokenHash` CHAR(64) NOT NULL UNIQUE,

  `deviceName` VARCHAR(150) DEFAULT NULL,

  `deviceType` ENUM(
    'desktop',
    'tablet',
    'mobile',
    'unknown'
  ) NOT NULL DEFAULT 'desktop',

  `ipAddress` VARCHAR(45) DEFAULT NULL,

  `userAgent` VARCHAR(500) DEFAULT NULL,

  `lastActiveAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  `expiresAt` DATETIME NOT NULL,

  `revokedAt` DATETIME DEFAULT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_admin_sessions_staffId` (`staffId`),
  KEY `idx_admin_sessions_expiresAt` (`expiresAt`),
  KEY `idx_admin_sessions_revokedAt` (`revokedAt`),

  CONSTRAINT `fk_admin_sessions_staff`
    FOREIGN KEY (`staffId`)
    REFERENCES `admin_staff` (`id`)
    ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;