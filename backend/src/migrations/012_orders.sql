-- =========================
-- 12. Orders Table
-- =========================
CREATE TABLE IF NOT EXISTS `orders` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `orderReference` VARCHAR(100) NOT NULL UNIQUE,
  `userId` INT UNSIGNED NOT NULL,
  `tokenId` INT UNSIGNED NOT NULL,
  `listingId` BIGINT UNSIGNED DEFAULT NULL,
  `orderType` ENUM('buy','sell') NOT NULL,
  `quantity` DECIMAL(30,8) NOT NULL,
  `filledQuantity` DECIMAL(30,8) NOT NULL DEFAULT 0,
  `pricePerToken` DECIMAL(20,8) NOT NULL,
  `totalAmount` DECIMAL(20,2) NOT NULL,
  `currency` VARCHAR(10) NOT NULL DEFAULT 'KES',
  `status` ENUM('pending','open','partially_filled','filled','cancelled','rejected','expired') DEFAULT 'pending',
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_orders_userId` (`userId`),
  KEY `idx_orders_tokenId` (`tokenId`),
  KEY `idx_orders_listingId` (`listingId`),
  KEY `idx_orders_status` (`status`),
  CONSTRAINT `fk_orders_user`
    FOREIGN KEY (`userId`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_orders_token`
    FOREIGN KEY (`tokenId`) REFERENCES `tokens` (`id`),
  CONSTRAINT `fk_orders_listing`
    FOREIGN KEY (`listingId`) REFERENCES `listings` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;