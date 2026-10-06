  -- =========================================================
-- 033 ADMIN STAFF
-- =========================================================

CREATE TABLE IF NOT EXISTS `admin_staff` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,

  `firstName` VARCHAR(100) NOT NULL,
  `lastName` VARCHAR(100) NOT NULL,

  `email` VARCHAR(150) NOT NULL UNIQUE,
  `phone` VARCHAR(20) DEFAULT NULL UNIQUE,

  `passwordHash` VARCHAR(255) NOT NULL,

  `roleId` INT UNSIGNED NOT NULL,

  `profilePhotoUrl` VARCHAR(255) DEFAULT NULL,

  `accountStatus` ENUM(
    'active',
    'suspended',
    'deactivated',
    'locked'
  ) NOT NULL DEFAULT 'active',

  `lastLoginAt` DATETIME DEFAULT NULL,

  `passwordChangedAt` DATETIME DEFAULT NULL,

  `failedLoginAttempts` INT UNSIGNED NOT NULL DEFAULT 0,

  `lockedUntil` DATETIME DEFAULT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_admin_staff_roleId` (`roleId`),
  KEY `idx_admin_staff_status` (`accountStatus`),
  KEY `idx_admin_staff_lastLogin` (`lastLoginAt`),

  CONSTRAINT `fk_admin_staff_role`
    FOREIGN KEY (`roleId`)
    REFERENCES `admin_roles` (`id`)
    ON DELETE RESTRICT

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;