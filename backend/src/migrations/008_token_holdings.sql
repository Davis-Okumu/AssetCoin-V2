-- =========================
-- 8. Token Holdings Table
-- =========================
CREATE TABLE IF NOT EXISTS `token_holdings` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `userId` INT UNSIGNED NOT NULL,
  `tokenId` INT UNSIGNED NOT NULL,
  `quantity` DECIMAL(30,8) NOT NULL DEFAULT 0,
  `lockedQuantity` DECIMAL(30,8) NOT NULL DEFAULT 0,
  `averageBuyPrice` DECIMAL(20,8) DEFAULT NULL,
  `totalInvested` DECIMAL(20,2) DEFAULT NULL,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_tokenHolding_user_token` (`userId`,`tokenId`),
  KEY `idx_holdings_tokenId` (`tokenId`),
  CONSTRAINT `fk_holdings_user`
    FOREIGN KEY (`userId`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_holdings_token`
    FOREIGN KEY (`tokenId`) REFERENCES `tokens` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;