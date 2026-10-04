-- =========================
-- 4. Asset Photos Table
-- =========================
CREATE TABLE IF NOT EXISTS `asset_photos` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `assetId` INT UNSIGNED NOT NULL,
  `photoUrl` VARCHAR(255) NOT NULL,
  `isPrimary` BOOLEAN NOT NULL DEFAULT FALSE,
  `displayOrder` INT UNSIGNED NOT NULL DEFAULT 0,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_assetPhotos_assetId` (`assetId`),
  CONSTRAINT `fk_assetPhotos_asset`
    FOREIGN KEY (`assetId`) REFERENCES `assets` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;