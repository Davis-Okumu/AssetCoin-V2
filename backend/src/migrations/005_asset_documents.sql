-- =========================
-- 5. Asset Documents Table
-- =========================
CREATE TABLE IF NOT EXISTS `asset_documents` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `assetId` INT UNSIGNED NOT NULL,
  `documentType` ENUM('ownership','valuation','registration','identification','legal','inspection','other') NOT NULL,
  `documentName` VARCHAR(150) NOT NULL,
  `documentUrl` VARCHAR(255) NOT NULL,
  `documentHash` CHAR(64) DEFAULT NULL,
  `status` ENUM('pending','verified','rejected') DEFAULT 'pending',
  `verifiedBy` INT UNSIGNED DEFAULT NULL,
  `verifiedAt` DATETIME DEFAULT NULL,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_assetDocuments_assetId` (`assetId`),
  CONSTRAINT `fk_assetDocuments_asset`
    FOREIGN KEY (`assetId`) REFERENCES `assets` (`id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_assetDocuments_verifiedBy`
    FOREIGN KEY (`verifiedBy`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;