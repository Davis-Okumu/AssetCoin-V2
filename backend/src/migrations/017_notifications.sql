-- =========================================================
-- COMMUNICATION
-- =========================================================


-- =========================
-- 17. Notifications Table
-- =========================
CREATE TABLE IF NOT EXISTS `notifications` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  `userId` INT UNSIGNED NOT NULL,
  `type` ENUM('system','trading','wallet','kyc','asset','security') NOT NULL,
  `title` VARCHAR(200) NOT NULL,
  `message` TEXT NOT NULL,
  `referenceType` VARCHAR(100) DEFAULT NULL,
  `referenceId` BIGINT UNSIGNED DEFAULT NULL,
  `deliveryMethod` ENUM('in_app','email','sms') DEFAULT 'in_app',
  `status` ENUM('new','viewed','sent','failed') DEFAULT 'new',
  `readAt` DATETIME DEFAULT NULL,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_notifications_userId` (`userId`),
  KEY `idx_notifications_status` (`status`),
  KEY `idx_notifications_type` (`type`),
  CONSTRAINT `fk_notifications_user`
    FOREIGN KEY (`userId`) REFERENCES `users` (`id`)
    ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;