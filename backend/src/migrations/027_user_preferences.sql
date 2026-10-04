
-- =========================================================
-- 27. User Preferences Table
-- =========================================================

CREATE TABLE IF NOT EXISTS `user_preferences` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `userId` INT UNSIGNED NOT NULL,

  -- Application appearance
  `theme` ENUM('light','dark','system') NOT NULL DEFAULT 'light',

  -- Application localization
  `language` VARCHAR(10) NOT NULL DEFAULT 'en',
  `displayCurrency` VARCHAR(10) NOT NULL DEFAULT 'KES',

  -- Privacy preferences
  `profileVisibility` ENUM('private','public') NOT NULL DEFAULT 'private',

  `showEmail` BOOLEAN NOT NULL DEFAULT FALSE,
  `showPhone` BOOLEAN NOT NULL DEFAULT FALSE,

  -- Account preferences
  `marketingNotificationsEnabled` BOOLEAN NOT NULL DEFAULT FALSE,
  `emailUpdatesEnabled` BOOLEAN NOT NULL DEFAULT TRUE,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  UNIQUE KEY `uq_user_preferences_userId` (`userId`),

  CONSTRAINT `fk_user_preferences_user`
    FOREIGN KEY (`userId`) REFERENCES `users` (`id`)
    ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;