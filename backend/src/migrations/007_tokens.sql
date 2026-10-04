-- =========================
-- 7. Tokens Table
-- =========================
CREATE TABLE IF NOT EXISTS `tokens` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `assetId` INT UNSIGNED NOT NULL,
  `tokenCode` VARCHAR(50) NOT NULL UNIQUE,
  `tokenName` VARCHAR(150) NOT NULL,
  `description` TEXT DEFAULT NULL,
  `totalSupply` DECIMAL(30,8) NOT NULL,
  `availableSupply` DECIMAL(30,8) NOT NULL,
  `tokenPrice` DECIMAL(20,8) NOT NULL,
  `currency` VARCHAR(10) NOT NULL DEFAULT 'KES',
  `decimals` TINYINT UNSIGNED NOT NULL DEFAULT 8,
  `status` ENUM('pending','active','paused','fully_sold','burned','suspended') DEFAULT 'pending',
  `mintedAt` DATETIME DEFAULT NULL,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_tokens_assetId` (`assetId`),
  KEY `idx_tokens_status` (`status`),
  CONSTRAINT `fk_tokens_asset`
    FOREIGN KEY (`assetId`) REFERENCES `assets` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;