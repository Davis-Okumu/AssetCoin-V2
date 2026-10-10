
-- =========================
-- 18. Announcements Table
-- =========================

CREATE TABLE IF NOT EXISTS `announcements` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(200) NOT NULL,
  `content` TEXT NOT NULL,
  `imageUrl` VARCHAR(255) DEFAULT NULL,

  `status` ENUM('draft','published','archived')
    NOT NULL DEFAULT 'draft',

  -- Preserve customer-user authorship.
  `publishedBy` INT UNSIGNED DEFAULT NULL,

  -- Administrator who published the announcement.
  `publishedByStaffId` INT UNSIGNED DEFAULT NULL,

  `publishedAt` DATETIME DEFAULT NULL,
  `expiresAt` DATETIME DEFAULT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_announcements_status` (`status`),
  KEY `idx_announcements_publishedAt` (`publishedAt`),
  KEY `idx_announcements_publishedByStaffId` (`publishedByStaffId`),

  CONSTRAINT `fk_announcements_publishedBy`
    FOREIGN KEY (`publishedBy`) REFERENCES `users` (`id`),

  CONSTRAINT `fk_announcements_publishedByStaff`
    FOREIGN KEY (`publishedByStaffId`)
    REFERENCES `admin_staff` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
