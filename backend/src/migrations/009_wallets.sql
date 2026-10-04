-- =========================
-- 9. Wallets Table
-- =========================
CREATE TABLE IF NOT EXISTS `wallets` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `userId` INT UNSIGNED NOT NULL,
  `walletAddress` VARCHAR(100) NOT NULL UNIQUE,
  `fiatBalance` DECIMAL(20,2) NOT NULL DEFAULT 0.00,
  `lockedFiatBalance` DECIMAL(20,2) NOT NULL DEFAULT 0.00,
  `currency` VARCHAR(10) NOT NULL DEFAULT 'KES',
  `status` ENUM('active','frozen','closed') DEFAULT 'active',
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_wallet_user` (`userId`),
  CONSTRAINT `fk_wallets_user`
    FOREIGN KEY (`userId`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;