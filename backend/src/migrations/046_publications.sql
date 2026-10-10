
-- ============================================================
-- MIGRATION 046: CONTENT MANAGEMENT
-- ============================================================
-- Creates the publications table.
-- Announcements and news are defined in their original
-- table-creation migrations.
-- ============================================================

CREATE TABLE IF NOT EXISTS `publications` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,

  `title` VARCHAR(250) NOT NULL,
  `summary` VARCHAR(500) DEFAULT NULL,
  `content` LONGTEXT DEFAULT NULL,

  `imageUrl` VARCHAR(255) DEFAULT NULL,
  `documentUrl` VARCHAR(500) DEFAULT NULL,

  `category` ENUM(
    'education',
    'guide',
    'report',
    'platform',
    'general'
  ) NOT NULL DEFAULT 'general',

  `status` ENUM('draft','published','archived')
    NOT NULL DEFAULT 'draft',

  `authorStaffId` INT UNSIGNED DEFAULT NULL,
  `publishedAt` DATETIME DEFAULT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_publications_status_publishedAt`
    (`status`, `publishedAt`),

  KEY `idx_publications_category` (`category`),
  KEY `idx_publications_authorStaffId` (`authorStaffId`),

  CONSTRAINT `fk_publications_authorStaff`
    FOREIGN KEY (`authorStaffId`)
    REFERENCES `admin_staff` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
