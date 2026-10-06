-- =========================================================
-- 043 ADMIN KYC WORKFLOW
-- =========================================================


-- =========================================================
-- 1. UPDATE KYC STATUS VALUES
-- =========================================================
--
-- Adds changes_required so a KYC officer can request
-- additional information/documents without rejecting
-- the entire application.
--

ALTER TABLE `kyc_records`
MODIFY COLUMN `status`
ENUM(
  'pending',
  'under_review',
  'changes_required',
  'verified',
  'rejected'
)
NOT NULL DEFAULT 'pending';


-- =========================================================
-- 2. CHANGE verifiedBy TO ADMIN STAFF
-- =========================================================
--
-- KYC verification is performed by administrative staff,
-- not customer users.
--

ALTER TABLE `kyc_records`
DROP FOREIGN KEY `fk_kyc_verifiedBy`;

ALTER TABLE `kyc_records`
ADD CONSTRAINT `fk_kyc_verifiedBy`
  FOREIGN KEY (`verifiedBy`)
  REFERENCES `admin_staff` (`id`)
  ON DELETE SET NULL;


-- =========================================================
-- 3. KYC REVIEWS
-- =========================================================

CREATE TABLE IF NOT EXISTS `kyc_reviews` (
  `id` BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

  `kycId` INT UNSIGNED NOT NULL,

  `adminId` INT UNSIGNED NOT NULL,

  `previousStatus` ENUM(
    'pending',
    'under_review',
    'changes_required',
    'verified',
    'rejected'
  ) DEFAULT NULL,

  `newStatus` ENUM(
    'pending',
    'under_review',
    'changes_required',
    'verified',
    'rejected'
  ) NOT NULL,

  `comments` TEXT DEFAULT NULL,

  `rejectionReason` TEXT DEFAULT NULL,

  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

  PRIMARY KEY (`id`),

  KEY `idx_kyc_reviews_kycId`
    (`kycId`),

  KEY `idx_kyc_reviews_adminId`
    (`adminId`),

  KEY `idx_kyc_reviews_status`
    (`newStatus`),

  KEY `idx_kyc_reviews_createdAt`
    (`createdAt`),

  CONSTRAINT `fk_kyc_reviews_kyc`
    FOREIGN KEY (`kycId`)
    REFERENCES `kyc_records` (`id`)
    ON DELETE CASCADE,

  CONSTRAINT `fk_kyc_reviews_admin`
    FOREIGN KEY (`adminId`)
    REFERENCES `admin_staff` (`id`)
    ON DELETE RESTRICT

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;