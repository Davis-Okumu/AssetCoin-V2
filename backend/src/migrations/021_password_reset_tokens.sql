CREATE TABLE IF NOT EXISTS password_reset_tokens (
    id INT UNSIGNED NOT NULL AUTO_INCREMENT,
    userId INT UNSIGNED NOT NULL,
    tokenHash VARCHAR(255) NOT NULL,
    expiresAt DATETIME NOT NULL,
    usedAt DATETIME DEFAULT NULL,
    createdAt DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY (id),

    INDEX idx_password_reset_user (userId),
    INDEX idx_password_reset_token (tokenHash),
    INDEX idx_password_reset_expiry (expiresAt),

    CONSTRAINT fk_password_reset_user
        FOREIGN KEY (userId)
        REFERENCES users(id)
        ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;