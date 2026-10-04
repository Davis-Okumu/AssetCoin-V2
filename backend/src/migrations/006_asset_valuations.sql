-- =========================
-- 6. Asset Valuations Table
-- =========================
CREATE TABLE IF NOT EXISTS `asset_valuations` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `assetId` INT UNSIGNED NOT NULL,
  `valuationAmount` DECIMAL(20,2) NOT NULL,
  `currency` VARCHAR(10) NOT NULL DEFAULT 'KES',
  `valuationMethod` ENUM('manual','professional','market','automated') NOT NULL,
  `valuerName` VARCHAR(150) DEFAULT NULL,
  `valuationDocumentId` INT UNSIGNED DEFAULT NULL,
  `notes` TEXT DEFAULT NULL,
  `status` ENUM('pending','verified','rejected') DEFAULT 'pending',
  `valuedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_valuations_assetId` (`assetId`),
  CONSTRAINT `fk_valuations_asset`
    FOREIGN KEY (`assetId`) REFERENCES `assets` (`id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_valuations_document`
    FOREIGN KEY (`valuationDocumentId`) REFERENCES `asset_documents` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;