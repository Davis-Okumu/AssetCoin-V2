-- =========================================================
-- 034 ADMIN STAFF PERMISSIONS
-- =========================================================

CREATE TABLE IF NOT EXISTS `admin_staff_permissions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

  `staffId` INT UNSIGNED NOT NULL,
  `permissionId` INT UNSIGNED NOT NULL,

  `accessType` ENUM(
    'grant',
    'deny'
  ) NOT NULL DEFAULT 'grant',

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  UNIQUE KEY `uq_admin_staff_permission`
    (`staffId`, `permissionId`),

  KEY `idx_admin_staff_permissions_staff`
    (`staffId`),

  KEY `idx_admin_staff_permissions_permission`
    (`permissionId`),

  CONSTRAINT `fk_admin_staff_permissions_staff`
    FOREIGN KEY (`staffId`)
    REFERENCES `admin_staff` (`id`)
    ON DELETE CASCADE,

  CONSTRAINT `fk_admin_staff_permissions_permission`
    FOREIGN KEY (`permissionId`)
    REFERENCES `admin_permissions` (`id`)
    ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;