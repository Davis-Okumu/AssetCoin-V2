
-- =========================
-- 19. News Table
-- =========================

CREATE TABLE IF NOT EXISTS `news` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `title` VARCHAR(250) NOT NULL,
  `summary` VARCHAR(500) DEFAULT NULL,
  `content` LONGTEXT NOT NULL,
  `imageUrl` VARCHAR(255) DEFAULT NULL,

  `category` ENUM(
    'market',
    'asset',
    'tokenization',
    'education',
    'company',
    'general'
  ) NOT NULL DEFAULT 'general',

  `status` ENUM('draft','published','archived')
    NOT NULL DEFAULT 'draft',

  -- Preserve customer-user authorship.
  `authorId` INT UNSIGNED DEFAULT NULL,

  -- Administrator who authored the article.
  `authorStaffId` INT UNSIGNED DEFAULT NULL,

  `publishedAt` DATETIME DEFAULT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_news_category` (`category`),
  KEY `idx_news_status` (`status`),
  KEY `idx_news_publishedAt` (`publishedAt`),
  KEY `idx_news_authorStaffId` (`authorStaffId`),

  CONSTRAINT `fk_news_author`
    FOREIGN KEY (`authorId`) REFERENCES `users` (`id`),

  CONSTRAINT `fk_news_authorStaff`
    FOREIGN KEY (`authorStaffId`)
    REFERENCES `admin_staff` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
