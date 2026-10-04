-- =========================================================
-- LEDGER & AUDITING
-- =========================================================


-- =========================
-- 15. Ledger Entries Table
-- =========================
CREATE TABLE IF NOT EXISTS `ledger_entries` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `entryReference` VARCHAR(100) NOT NULL UNIQUE,
  `userId` INT UNSIGNED DEFAULT NULL,
  `walletId` INT UNSIGNED DEFAULT NULL,
  `tokenId` INT UNSIGNED DEFAULT NULL,
  `transactionId` BIGINT UNSIGNED DEFAULT NULL,
  `entryType` ENUM('debit','credit') NOT NULL,
  `assetType` ENUM('fiat','token') NOT NULL,
  `amount` DECIMAL(30,8) NOT NULL,
  `currency` VARCHAR(10) DEFAULT NULL,
  `balanceBefore` DECIMAL(30,8) DEFAULT NULL,
  `balanceAfter` DECIMAL(30,8) DEFAULT NULL,
  `description` VARCHAR(255) DEFAULT NULL,
  `previousHash` CHAR(64) DEFAULT NULL,
  `entryHash` CHAR(64) NOT NULL UNIQUE,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_ledger_userId` (`userId`),
  KEY `idx_ledger_walletId` (`walletId`),
  KEY `idx_ledger_tokenId` (`tokenId`),
  KEY `idx_ledger_createdAt` (`createdAt`),
  CONSTRAINT `fk_ledger_user`
    FOREIGN KEY (`userId`) REFERENCES `users` (`id`),
  CONSTRAINT `fk_ledger_wallet`
    FOREIGN KEY (`walletId`) REFERENCES `wallets` (`id`),
  CONSTRAINT `fk_ledger_token`
    FOREIGN KEY (`tokenId`) REFERENCES `tokens` (`id`),
  CONSTRAINT `fk_ledger_transaction`
    FOREIGN KEY (`transactionId`) REFERENCES `transactions` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;