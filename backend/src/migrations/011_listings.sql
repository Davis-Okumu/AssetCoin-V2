-- =========================
-- 11. Listings Table
-- =========================
CREATE TABLE IF NOT EXISTS `listings` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `sellerId` INT UNSIGNED NOT NULL,
  `tokenId` INT UNSIGNED NOT NULL,
  `quantity` DECIMAL(30,8) NOT NULL,
  `remainingQuantity` DECIMAL(30,8) NOT NULL,
  `pricePerToken` DECIMAL(20,8) NOT NULL,
  `currency` VARCHAR(10) NOT NULL DEFAULT 'KES',
  `listingType` ENUM('sell','buy') NOT NULL DEFAULT 'sell',
  `status` ENUM('active','partially_filled','filled','cancelled','expired','suspended') DEFAULT 'active',
  `expiresAt` DATETIME DEFAULT NULL,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_listings_sellerId` (`sellerId`),
  KEY `idx_listings_tokenId` (`tokenId`),
  KEY `idx_listings_status` (`status`),
  CONSTRAINT `fk_listings_seller`
    FOREIGN KEY (`sellerId`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_listings_token`
    FOREIGN KEY (`tokenId`) REFERENCES `tokens` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;