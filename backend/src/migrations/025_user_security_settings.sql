
-- =========================================================
-- 25. User Security Settings Table
-- =========================================================

CREATE TABLE IF NOT EXISTS `user_security_settings` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `userId` INT UNSIGNED NOT NULL UNIQUE,

  -- Biometric login preference
  -- Actual biometric authentication is handled locally
  -- by the user's device.
  `biometricEnabled` BOOLEAN NOT NULL DEFAULT FALSE,

  -- Two-factor authentication
  `twoFactorEnabled` BOOLEAN NOT NULL DEFAULT FALSE,

  `twoFactorMethod` ENUM(
    'authenticator',
    'email',
    'sms'
  ) DEFAULT NULL,

  `twoFactorSecret` VARCHAR(255) DEFAULT NULL,

  `twoFactorVerifiedAt` DATETIME DEFAULT NULL,

  -- Security preferences
  `loginNotificationEnabled` BOOLEAN NOT NULL DEFAULT TRUE,

  `passwordChangedAt` DATETIME DEFAULT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_security_settings_userId` (`userId`),

  CONSTRAINT `fk_security_settings_user`
    FOREIGN KEY (`userId`) REFERENCES `users` (`id`)
    ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;