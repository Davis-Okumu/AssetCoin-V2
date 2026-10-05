-- =========================================================
-- 036 ADMIN PASSWORD RESET TOKENS
-- =========================================================

CREATE TABLE IF NOT EXISTS `admin_password_reset_tokens` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,

  `staffId` INT UNSIGNED NOT NULL,

  `tokenHash` VARCHAR(255) NOT NULL,

  `expiresAt` DATETIME NOT NULL,

  `usedAt` DATETIME DEFAULT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_admin_password_reset_staff`
    (`staffId`),

  KEY `idx_admin_password_reset_token`
    (`tokenHash`),

  KEY `idx_admin_password_reset_expiry`
    (`expiresAt`),

  CONSTRAINT `fk_admin_password_reset_staff`
    FOREIGN KEY (`staffId`)
    REFERENCES `admin_staff` (`id`)
    ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;