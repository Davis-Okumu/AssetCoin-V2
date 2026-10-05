-- =========================================================
-- 042 ADMIN SETTINGS
-- =========================================================

CREATE TABLE IF NOT EXISTS `admin_settings` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,

  `settingKey` VARCHAR(150) NOT NULL UNIQUE,

  `settingValue` TEXT DEFAULT NULL,

  `settingType` ENUM(
    'string',
    'integer',
    'decimal',
    'boolean',
    'json'
  ) NOT NULL DEFAULT 'string',

  `description` VARCHAR(255) DEFAULT NULL,

  `isSensitive` BOOLEAN NOT NULL DEFAULT FALSE,

  `updatedBy` INT UNSIGNED DEFAULT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_admin_settings_updatedBy`
    (`updatedBy`),

  CONSTRAINT `fk_admin_settings_updatedBy`
    FOREIGN KEY (`updatedBy`)
    REFERENCES `admin_staff` (`id`)
    ON DELETE SET NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;