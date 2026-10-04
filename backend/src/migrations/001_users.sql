-- =========================
-- 1. Users Table
-- =========================
CREATE TABLE IF NOT EXISTS `users` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
  `firstName` VARCHAR(100) NOT NULL,
  `lastName` VARCHAR(100) NOT NULL,
  `phone` VARCHAR(20) NOT NULL UNIQUE,
  `email` VARCHAR(150) UNIQUE,
  `nationalId` VARCHAR(50) NOT NULL UNIQUE,
  `idDocumentUrl` VARCHAR(255) DEFAULT NULL,
  `profilePhotoUrl` VARCHAR(255) DEFAULT NULL,
  `passwordHash` VARCHAR(255) NOT NULL,
  `kycStatus` ENUM('pending','verified','rejected') DEFAULT 'pending',
  `role` ENUM('user','admin') DEFAULT 'user',
  `accountStatus` ENUM('active','suspended','deactivated','deleted') DEFAULT 'active',
  `lastLoginAt` DATETIME DEFAULT NULL,
  `createdAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updatedAt` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;