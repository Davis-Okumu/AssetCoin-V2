-- =========================
-- 2. KYC Records Table
-- =========================
CREATE TABLE IF NOT EXISTS `kyc_records` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `userId` INT UNSIGNED NOT NULL,
  `nationalId` VARCHAR(50) NOT NULL,
  `idDocumentUrl` VARCHAR(255) DEFAULT NULL,
  `selfieUrl` VARCHAR(255) DEFAULT NULL,
  `verificationMethod` ENUM('manual','automated') DEFAULT 'manual',
  `status` ENUM('pending','under_review','verified','rejected') DEFAULT 'pending',
  `rejectionReason` TEXT DEFAULT NULL,
  `verifiedBy` INT UNSIGNED DEFAULT NULL,
  `verifiedAt` DATETIME DEFAULT NULL,
  `submittedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_kyc_userId` (`userId`),
  KEY `idx_kyc_status` (`status`),
  CONSTRAINT `fk_kyc_user`
    FOREIGN KEY (`userId`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_kyc_verifiedBy`
    FOREIGN KEY (`verifiedBy`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;