-- =========================
-- 14. Token Price History Table
-- =========================
CREATE TABLE IF NOT EXISTS `token_price_history` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `tokenId` INT UNSIGNED NOT NULL,
  `price` DECIMAL(20,8) NOT NULL,
  `currency` VARCHAR(10) NOT NULL DEFAULT 'KES',
  `source` ENUM('market','manual','valuation','transaction') NOT NULL,
  `referenceId` BIGINT UNSIGNED DEFAULT NULL,
  `recordedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_priceHistory_tokenId` (`tokenId`),
  KEY `idx_priceHistory_recordedAt` (`recordedAt`),
  CONSTRAINT `fk_priceHistory_token`
    FOREIGN KEY (`tokenId`) REFERENCES `tokens` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;