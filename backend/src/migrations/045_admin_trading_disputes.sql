/**
 * AssetCoin
 * Migration 045
 *
 * Admin Marketplace & Trading
 *
 * Purpose:
 * - Add trading dispute management.
 * - Support dispute assignment to admin staff.
 * - Support dispute resolution and auditability.
 * - Suspended listings continue to use listings.status = 'suspended'.
 *
 * Important:
 * - Customer trading execution remains in tradingService.js.
 * - This migration only adds administrative dispute management.
 */

-- =========================================================
-- 045 TRADING DISPUTES
-- =========================================================

CREATE TABLE IF NOT EXISTS `trading_disputes` (

  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

  `disputeReference` VARCHAR(50) NOT NULL,

  /*
   * Financial/trading references
   */
  `transactionId` BIGINT UNSIGNED DEFAULT NULL,
  `orderId` BIGINT UNSIGNED DEFAULT NULL,
  `listingId` BIGINT UNSIGNED DEFAULT NULL,

  /*
   * Customer who raised the dispute
   */
  `raisedBy` INT UNSIGNED NOT NULL,

  /*
   * Customer on the other side of the dispute.
   * This may be NULL when the dispute is not
   * directly against another customer.
   */
  `againstUserId` INT UNSIGNED DEFAULT NULL,

  /*
   * Administrative staff responsible for the dispute.
   */
  `assignedTo` INT UNSIGNED DEFAULT NULL,

  /*
   * Type of dispute
   */
  `disputeType` ENUM(
    'trade',
    'listing',
    'order',
    'payment',
    'ownership',
    'other'
  ) NOT NULL DEFAULT 'trade',

  /*
   * Operational priority
   */
  `priority` ENUM(
    'low',
    'normal',
    'high',
    'critical'
  ) NOT NULL DEFAULT 'normal',

  /*
   * Dispute workflow
   */
  `status` ENUM(
    'open',
    'under_review',
    'awaiting_information',
    'resolved',
    'rejected',
    'closed'
  ) NOT NULL DEFAULT 'open',

  /*
   * Short reason/title
   */
  `reason` VARCHAR(255) NOT NULL,

  /*
   * Full dispute description
   */
  `description` TEXT DEFAULT NULL,

  /*
   * Administrative resolution
   */
  `resolutionNotes` TEXT DEFAULT NULL,

  /*
   * Staff member who resolved the dispute
   */
  `resolvedBy` INT UNSIGNED DEFAULT NULL,

  `resolvedAt` DATETIME DEFAULT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  UNIQUE KEY `uq_trading_disputes_reference`
    (`disputeReference`),

  KEY `idx_trading_disputes_transaction`
    (`transactionId`),

  KEY `idx_trading_disputes_order`
    (`orderId`),

  KEY `idx_trading_disputes_listing`
    (`listingId`),

  KEY `idx_trading_disputes_raised_by`
    (`raisedBy`),

  KEY `idx_trading_disputes_against_user`
    (`againstUserId`),

  KEY `idx_trading_disputes_assigned_to`
    (`assignedTo`),

  KEY `idx_trading_disputes_resolved_by`
    (`resolvedBy`),

  KEY `idx_trading_disputes_status`
    (`status`),

  KEY `idx_trading_disputes_priority`
    (`priority`),

  KEY `idx_trading_disputes_created_at`
    (`createdAt`),

  /*
   * Trading references
   */

  CONSTRAINT `fk_trading_disputes_transaction`
    FOREIGN KEY (`transactionId`)
    REFERENCES `transactions` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,

  CONSTRAINT `fk_trading_disputes_order`
    FOREIGN KEY (`orderId`)
    REFERENCES `orders` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,

  CONSTRAINT `fk_trading_disputes_listing`
    FOREIGN KEY (`listingId`)
    REFERENCES `listings` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,

  /*
   * Customer references
   */

  CONSTRAINT `fk_trading_disputes_raised_by`
    FOREIGN KEY (`raisedBy`)
    REFERENCES `users` (`id`)
    ON DELETE RESTRICT
    ON UPDATE CASCADE,

  CONSTRAINT `fk_trading_disputes_against_user`
    FOREIGN KEY (`againstUserId`)
    REFERENCES `users` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,

  /*
   * Administrative staff references
   */

  CONSTRAINT `fk_trading_disputes_assigned_to`
    FOREIGN KEY (`assignedTo`)
    REFERENCES `admin_staff` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE,

  CONSTRAINT `fk_trading_disputes_resolved_by`
    FOREIGN KEY (`resolvedBy`)
    REFERENCES `admin_staff` (`id`)
    ON DELETE SET NULL
    ON UPDATE CASCADE

) ENGINE=InnoDB
  DEFAULT CHARSET=utf8mb4
  COLLATE=utf8mb4_unicode_ci;