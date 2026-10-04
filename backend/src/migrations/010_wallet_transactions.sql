-- =========================
-- 10. Wallet Transactions Table
-- =========================
CREATE TABLE IF NOT EXISTS `wallet_transactions` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `walletId` INT UNSIGNED NOT NULL,
  `userId` INT UNSIGNED NOT NULL,
  `transactionReference` VARCHAR(100) NOT NULL UNIQUE,
  `transactionType` ENUM('deposit','withdrawal','token_purchase','token_sale','conversion','refund','fee','adjustment') NOT NULL,
  `amount` DECIMAL(20,2) NOT NULL,
  `currency` VARCHAR(10) NOT NULL DEFAULT 'KES',
  `balanceBefore` DECIMAL(20,2) NOT NULL,
  `balanceAfter` DECIMAL(20,2) NOT NULL,
  `status` ENUM('pending','completed','failed','reversed') DEFAULT 'pending',
  `description` VARCHAR(255) DEFAULT NULL,
  `previousHash` CHAR(64) DEFAULT NULL,
  `transactionHash` CHAR(64) NOT NULL UNIQUE,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_walletTransactions_walletId` (`walletId`),
  KEY `idx_walletTransactions_userId` (`userId`),
  KEY `idx_walletTransactions_createdAt` (`createdAt`),
  CONSTRAINT `fk_walletTransactions_wallet`
    FOREIGN KEY (`walletId`) REFERENCES `wallets` (`id`),
  CONSTRAINT `fk_walletTransactions_user`
    FOREIGN KEY (`userId`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;