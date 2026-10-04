
-- =========================================================
-- 24. User Sessions Table
-- =========================================================

CREATE TABLE IF NOT EXISTS `user_sessions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `userId` INT UNSIGNED NOT NULL,

  `sessionTokenHash` CHAR(64) NOT NULL UNIQUE,

  `deviceName` VARCHAR(150) DEFAULT NULL,
  `deviceType` ENUM(
    'mobile',
    'desktop',
    'tablet',
    'unknown'
  ) NOT NULL DEFAULT 'unknown',

  `ipAddress` VARCHAR(45) DEFAULT NULL,
  `userAgent` VARCHAR(500) DEFAULT NULL,

  `lastActiveAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  `expiresAt` DATETIME NOT NULL,
  `revokedAt` DATETIME DEFAULT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_user_sessions_userId` (`userId`),
  KEY `idx_user_sessions_expiresAt` (`expiresAt`),
  KEY `idx_user_sessions_revokedAt` (`revokedAt`),

  CONSTRAINT `fk_user_sessions_user`
    FOREIGN KEY (`userId`) REFERENCES `users` (`id`)
    ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;