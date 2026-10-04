-- =========================
-- 13. Transactions Table
-- =========================
CREATE TABLE IF NOT EXISTS `transactions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `transactionReference` VARCHAR(100) NOT NULL UNIQUE,
  `buyerId` INT UNSIGNED NOT NULL,
  `sellerId` INT UNSIGNED NOT NULL,
  `tokenId` INT UNSIGNED NOT NULL,
  `listingId` BIGINT UNSIGNED DEFAULT NULL,
  `buyOrderId` BIGINT UNSIGNED DEFAULT NULL,
  `sellOrderId` BIGINT UNSIGNED DEFAULT NULL,
  `quantity` DECIMAL(30,8) NOT NULL,
  `pricePerToken` DECIMAL(20,8) NOT NULL,
  `totalAmount` DECIMAL(20,2) NOT NULL,
  `feeAmount` DECIMAL(20,2) NOT NULL DEFAULT 0.00,
  `currency` VARCHAR(10) NOT NULL DEFAULT 'KES',
  `status` ENUM('pending','completed','failed','reversed') DEFAULT 'pending',
  `previousHash` CHAR(64) DEFAULT NULL,
  `transactionHash` CHAR(64) NOT NULL UNIQUE,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_transactions_buyerId` (`buyerId`),
  KEY `idx_transactions_sellerId` (`sellerId`),
  KEY `idx_transactions_tokenId` (`tokenId`),
  KEY `idx_transactions_createdAt` (`createdAt`),
  CONSTRAINT `fk_transactions_buyer`
    FOREIGN KEY (`buyerId`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_transactions_seller`
    FOREIGN KEY (`sellerId`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_transactions_token`
    FOREIGN KEY (`tokenId`) REFERENCES `tokens` (`id`),
  CONSTRAINT `fk_transactions_listing`
    FOREIGN KEY (`listingId`) REFERENCES `listings` (`id`),
  CONSTRAINT `fk_transactions_buyOrder`
    FOREIGN KEY (`buyOrderId`) REFERENCES `orders` (`id`),
  CONSTRAINT `fk_transactions_sellOrder`
    FOREIGN KEY (`sellOrderId`) REFERENCES `orders` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;