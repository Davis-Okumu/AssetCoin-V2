-- =========================
-- 21. Asset Reviews Table
-- =========================
CREATE TABLE IF NOT EXISTS `asset_reviews` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `assetId` INT UNSIGNED NOT NULL,
  `adminId` INT UNSIGNED NOT NULL,

  `decision` ENUM(
    'under_review',
    'changes_required',
    'approved',
    'rejected'
  ) NOT NULL,

  `comments` TEXT DEFAULT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_asset_reviews_assetId` (`assetId`),
  KEY `idx_asset_reviews_adminId` (`adminId`),
  KEY `idx_asset_reviews_decision` (`decision`),

  CONSTRAINT `fk_asset_reviews_asset`
    FOREIGN KEY (`assetId`) REFERENCES `assets` (`id`)
    ON DELETE CASCADE,

  CONSTRAINT `fk_asset_reviews_admin`
    FOREIGN KEY (`adminId`) REFERENCES `users` (`id`)
    ON DELETE RESTRICT

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;