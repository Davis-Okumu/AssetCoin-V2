-- =========================
-- 18. Announcements Table
-- =========================
CREATE TABLE IF NOT EXISTS `announcements` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(200) NOT NULL,
  `content` TEXT NOT NULL,
  `imageUrl` VARCHAR(255) DEFAULT NULL,
  `status` ENUM('draft','published','archived') DEFAULT 'draft',
  `publishedBy` INT UNSIGNED DEFAULT NULL,
  `publishedAt` DATETIME DEFAULT NULL,
  `expiresAt` DATETIME DEFAULT NULL,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_announcements_status` (`status`),
  KEY `idx_announcements_publishedAt` (`publishedAt`),
  CONSTRAINT `fk_announcements_publishedBy`
    FOREIGN KEY (`publishedBy`) REFERENCES `users` (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;