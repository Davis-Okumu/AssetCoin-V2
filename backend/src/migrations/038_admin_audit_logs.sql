-- =========================================================
-- 038 ADMIN AUDIT LOGS
-- =========================================================

CREATE TABLE IF NOT EXISTS `admin_audit_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

  `staffId` INT UNSIGNED DEFAULT NULL,

  `action` VARCHAR(150) NOT NULL,

  `module` VARCHAR(100) NOT NULL,

  `entityType` VARCHAR(100) DEFAULT NULL,

  `entityId` BIGINT UNSIGNED DEFAULT NULL,

  `oldValues` JSON DEFAULT NULL,

  `newValues` JSON DEFAULT NULL,

  `ipAddress` VARCHAR(45) DEFAULT NULL,

  `userAgent` VARCHAR(500) DEFAULT NULL,

  `previousHash` CHAR(64) DEFAULT NULL,

  `logHash` CHAR(64) NOT NULL UNIQUE,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_admin_audit_staffId` (`staffId`),

  KEY `idx_admin_audit_module` (`module`),

  KEY `idx_admin_audit_entity`
    (`entityType`, `entityId`),

  KEY `idx_admin_audit_createdAt`
    (`createdAt`),

  CONSTRAINT `fk_admin_audit_staff`
    FOREIGN KEY (`staffId`)
    REFERENCES `admin_staff` (`id`)
    ON DELETE SET NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;