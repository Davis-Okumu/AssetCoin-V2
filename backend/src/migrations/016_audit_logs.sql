-- =========================
-- 16. Audit Logs Table
-- =========================
CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `userId` INT UNSIGNED DEFAULT NULL,
  `action` VARCHAR(100) NOT NULL,
  `entityType` VARCHAR(100) NOT NULL,
  `entityId` BIGINT UNSIGNED DEFAULT NULL,
  `oldValues` JSON DEFAULT NULL,
  `newValues` JSON DEFAULT NULL,
  `ipAddress` VARCHAR(45) DEFAULT NULL,
  `userAgent` VARCHAR(500) DEFAULT NULL,
  `previousHash` CHAR(64) DEFAULT NULL,
  `logHash` CHAR(64) NOT NULL UNIQUE,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_audit_userId` (`userId`),
  KEY `idx_audit_entity` (`entityType`,`entityId`),
  KEY `idx_audit_createdAt` (`createdAt`),
  CONSTRAINT `fk_audit_user`
    FOREIGN KEY (`userId`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;