
-- =========================================================
-- 28. Support Tickets Table
-- =========================================================

CREATE TABLE IF NOT EXISTS `support_tickets` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

  `ticketReference` VARCHAR(100) NOT NULL UNIQUE,

  `userId` INT UNSIGNED NOT NULL,

  `category` ENUM(
    'account',
    'kyc',
    'wallet',
    'trading',
    'assets',
    'payments',
    'technical',
    'security',
    'other'
  ) NOT NULL DEFAULT 'other',

  `subject` VARCHAR(200) NOT NULL,

  `description` TEXT NOT NULL,

  `priority` ENUM(
    'low',
    'normal',
    'high',
    'urgent'
  ) NOT NULL DEFAULT 'normal',

  `status` ENUM(
    'open',
    'in_progress',
    'waiting_for_user',
    'resolved',
    'closed'
  ) NOT NULL DEFAULT 'open',

  `assignedTo` INT UNSIGNED DEFAULT NULL,

  `resolvedAt` DATETIME DEFAULT NULL,

  `closedAt` DATETIME DEFAULT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_support_tickets_userId` (`userId`),
  KEY `idx_support_tickets_status` (`status`),
  KEY `idx_support_tickets_category` (`category`),
  KEY `idx_support_tickets_priority` (`priority`),
  KEY `idx_support_tickets_assignedTo` (`assignedTo`),
  KEY `idx_support_tickets_createdAt` (`createdAt`),

  CONSTRAINT `fk_support_tickets_user`
    FOREIGN KEY (`userId`) REFERENCES `users` (`id`)
    ON DELETE CASCADE,

  CONSTRAINT `fk_support_tickets_assignedTo`
    FOREIGN KEY (`assignedTo`) REFERENCES `users` (`id`)
    ON DELETE SET NULL

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================================================
-- 29. Support Ticket Messages Table
-- =========================================================

CREATE TABLE IF NOT EXISTS `support_ticket_messages` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

  `ticketId` BIGINT UNSIGNED NOT NULL,

  `senderId` INT UNSIGNED NOT NULL,

  `senderType` ENUM(
    'user',
    'admin'
  ) NOT NULL DEFAULT 'user',

  `message` TEXT NOT NULL,

  `isInternal` BOOLEAN NOT NULL DEFAULT FALSE,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_support_messages_ticketId` (`ticketId`),
  KEY `idx_support_messages_senderId` (`senderId`),
  KEY `idx_support_messages_createdAt` (`createdAt`),

  CONSTRAINT `fk_support_messages_ticket`
    FOREIGN KEY (`ticketId`) REFERENCES `support_tickets` (`id`)
    ON DELETE CASCADE,

  CONSTRAINT `fk_support_messages_sender`
    FOREIGN KEY (`senderId`) REFERENCES `users` (`id`)
    ON DELETE RESTRICT

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- =========================================================
-- 30. Support Ticket Attachments Table
-- =========================================================

CREATE TABLE IF NOT EXISTS `support_ticket_attachments` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

  `ticketId` BIGINT UNSIGNED NOT NULL,

  `messageId` BIGINT UNSIGNED DEFAULT NULL,

  `uploadedBy` INT UNSIGNED NOT NULL,

  `fileName` VARCHAR(255) NOT NULL,

  `fileUrl` VARCHAR(500) NOT NULL,

  `fileType` VARCHAR(100) NOT NULL,

  `fileSize` BIGINT UNSIGNED NOT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_support_attachments_ticketId` (`ticketId`),
  KEY `idx_support_attachments_messageId` (`messageId`),
  KEY `idx_support_attachments_uploadedBy` (`uploadedBy`),

  CONSTRAINT `fk_support_attachments_ticket`
    FOREIGN KEY (`ticketId`) REFERENCES `support_tickets` (`id`)
    ON DELETE CASCADE,

  CONSTRAINT `fk_support_attachments_message`
    FOREIGN KEY (`messageId`) REFERENCES `support_ticket_messages` (`id`)
    ON DELETE CASCADE,

  CONSTRAINT `fk_support_attachments_user`
    FOREIGN KEY (`uploadedBy`) REFERENCES `users` (`id`)
    ON DELETE RESTRICT

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;