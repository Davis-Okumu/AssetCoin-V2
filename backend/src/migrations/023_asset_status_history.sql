-- =========================
-- 22. Asset Status History Table
-- =========================
CREATE TABLE IF NOT EXISTS `asset_status_history` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `assetId` INT UNSIGNED NOT NULL,

  `previousStatus` ENUM(
    'draft',
    'pending',
    'under_review',
    'changes_required',
    'approved',
    'rejected',
    'tokenized',
    'suspended'
  ) DEFAULT NULL,

  `newStatus` ENUM(
    'draft',
    'pending',
    'under_review',
    'changes_required',
    'approved',
    'rejected',
    'tokenized',
    'suspended'
  ) NOT NULL,

  `changedBy` INT UNSIGNED DEFAULT NULL,
  `changeReason` TEXT DEFAULT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_asset_status_history_assetId` (`assetId`),
  KEY `idx_asset_status_history_changedBy` (`changedBy`),

  CONSTRAINT `fk_asset_status_history_asset`
    FOREIGN KEY (`assetId`) REFERENCES `assets` (`id`)
    ON DELETE CASCADE,

  CONSTRAINT `fk_asset_status_history_user`
    FOREIGN KEY (`changedBy`) REFERENCES `users` (`id`)
    ON DELETE SET NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;