
-- =========================================================
-- 029 USER NOTIFICATION PREFERENCES
-- =========================================================

CREATE TABLE IF NOT EXISTS user_notification_preferences (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,

  userId INT UNSIGNED NOT NULL,

  notificationType ENUM(
    'system',
    'trading',
    'wallet',
    'kyc',
    'asset',
    'security'
  ) NOT NULL,

  inAppEnabled BOOLEAN NOT NULL DEFAULT TRUE,
  emailEnabled BOOLEAN NOT NULL DEFAULT FALSE,
  smsEnabled BOOLEAN NOT NULL DEFAULT FALSE,

  createdAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

  updatedAt TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
    ON UPDATE CURRENT_TIMESTAMP,

  PRIMARY KEY (id),

  UNIQUE KEY unique_user_notification_type (
    userId,
    notificationType
  ),

  KEY idx_notification_preferences_user (userId),

  CONSTRAINT fk_notification_preferences_user
    FOREIGN KEY (userId)
    REFERENCES users(id)
    ON DELETE CASCADE

) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

