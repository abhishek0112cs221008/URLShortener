

CREATE DATABASE IF NOT EXISTS url_shortener 
CHARACTER SET utf8mb4 
COLLATE utf8mb4_unicode_ci;

USE url_shortener;

DROP TABLE IF EXISTS urls;

CREATE TABLE urls (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    long_url TEXT NOT NULL,
    short_code VARCHAR(10) UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_short_code (short_code),
    INDEX idx_created_at (created_at)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Sample query to check data
SELECT * FROM urls ORDER BY created_at DESC;
