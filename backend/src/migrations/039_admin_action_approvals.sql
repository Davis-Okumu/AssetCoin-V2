-- =========================================================
-- 039 ADMIN ACTION APPROVALS
-- =========================================================

CREATE TABLE IF NOT EXISTS `admin_action_approvals` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

  `actionReference` VARCHAR(100) NOT NULL UNIQUE,

  `module` VARCHAR(100) NOT NULL,

  `actionType` VARCHAR(100) NOT NULL,

  `entityType` VARCHAR(100) NOT NULL,

  `entityId` BIGINT UNSIGNED NOT NULL,

  `requestedBy` INT UNSIGNED NOT NULL,

  `reviewedBy` INT UNSIGNED DEFAULT NULL,

  `status` ENUM(
    'pending',
    'approved',
    'rejected',
    'cancelled',
    'expired'
  ) NOT NULL DEFAULT 'pending',

  `requestData` JSON DEFAULT NULL,

  `reviewComments` TEXT DEFAULT NULL,

  `requestedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  `reviewedAt` DATETIME DEFAULT NULL,

  `expiresAt` DATETIME DEFAULT NULL,

  PRIMARY KEY (`id`),

  KEY `idx_admin_approval_module`
    (`module`),

  KEY `idx_admin_approval_entity`
    (`entityType`, `entityId`),

  KEY `idx_admin_approval_requestedBy`
    (`requestedBy`),

  KEY `idx_admin_approval_reviewedBy`
    (`reviewedBy`),

  KEY `idx_admin_approval_status`
    (`status`),

  KEY `idx_admin_approval_requestedAt`
    (`requestedAt`),

  CONSTRAINT `fk_admin_approval_requestedBy`
    FOREIGN KEY (`requestedBy`)
    REFERENCES `admin_staff` (`id`)
    ON DELETE RESTRICT,

  CONSTRAINT `fk_admin_approval_reviewedBy`
    FOREIGN KEY (`reviewedBy`)
    REFERENCES `admin_staff` (`id`)
    ON DELETE SET NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;