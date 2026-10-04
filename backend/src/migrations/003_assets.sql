-- =========================
-- 3. Assets Table
-- =========================
CREATE TABLE IF NOT EXISTS `assets` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `ownerId` INT UNSIGNED NOT NULL,
  `assetCode` VARCHAR(50) NOT NULL UNIQUE,
  `assetType` ENUM('land','livestock','produce','vehicle','property','equipment','other') NOT NULL,
  `name` VARCHAR(150) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `location` VARCHAR(255) DEFAULT NULL,
  `latitude` DECIMAL(10,8) DEFAULT NULL,
  `longitude` DECIMAL(11,8) DEFAULT NULL,
  `registrationNumber` VARCHAR(100) DEFAULT NULL,
  `estimatedValue` DECIMAL(20,2) DEFAULT NULL,
  `currency` VARCHAR(10) NOT NULL DEFAULT 'KES',
  `status` ENUM('draft','pending','under_review','changes_required','approved','rejected','tokenized','suspended') DEFAULT 'draft',
  `rejectionReason` TEXT DEFAULT NULL,
  `approvedBy` INT UNSIGNED DEFAULT NULL,
  `approvedAt` DATETIME DEFAULT NULL,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_assets_ownerId` (`ownerId`),
  KEY `idx_assets_type` (`assetType`),
  KEY `idx_assets_status` (`status`),
  CONSTRAINT `fk_assets_owner`
    FOREIGN KEY (`ownerId`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_assets_approvedBy`
    FOREIGN KEY (`approvedBy`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;