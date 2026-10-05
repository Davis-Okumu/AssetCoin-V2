-- =========================================================
-- 040 ADMIN ASSIGNMENTS
-- =========================================================

CREATE TABLE IF NOT EXISTS `admin_assignments` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

  `assignmentReference` VARCHAR(100) NOT NULL UNIQUE,

  `module` VARCHAR(100) NOT NULL,

  `entityType` VARCHAR(100) NOT NULL,

  `entityId` BIGINT UNSIGNED NOT NULL,

  `assignedTo` INT UNSIGNED NOT NULL,

  `assignedBy` INT UNSIGNED NOT NULL,

  `status` ENUM(
    'assigned',
    'in_progress',
    'completed',
    'cancelled'
  ) NOT NULL DEFAULT 'assigned',

  `priority` ENUM(
    'low',
    'normal',
    'high',
    'urgent'
  ) NOT NULL DEFAULT 'normal',

  `notes` TEXT DEFAULT NULL,

  `assignedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  `startedAt` DATETIME DEFAULT NULL,

  `completedAt` DATETIME DEFAULT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_admin_assignments_module`
    (`module`),

  KEY `idx_admin_assignments_entity`
    (`entityType`, `entityId`),

  KEY `idx_admin_assignments_assignedTo`
    (`assignedTo`),

  KEY `idx_admin_assignments_assignedBy`
    (`assignedBy`),

  KEY `idx_admin_assignments_status`
    (`status`),

  KEY `idx_admin_assignments_priority`
    (`priority`),

  CONSTRAINT `fk_admin_assignments_assignedTo`
    FOREIGN KEY (`assignedTo`)
    REFERENCES `admin_staff` (`id`)
    ON DELETE RESTRICT,

  CONSTRAINT `fk_admin_assignments_assignedBy`
    FOREIGN KEY (`assignedBy`)
    REFERENCES `admin_staff` (`id`)
    ON DELETE RESTRICT

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;