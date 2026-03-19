-- This script creates the database and tables for the UPGRADED CarShowcase Hub project.
-- It includes users, showrooms, and links cars to showrooms.

-- Drop the database if it exists to start fresh, then create it.
DROP DATABASE IF EXISTS `car_showcase_db`;
CREATE DATABASE IF NOT EXISTS `car_showcase_db`;
USE `car_showcase_db`;

-- 1. Table: showrooms
-- Stores showroom information. Must be created before users and cars.
CREATE TABLE IF NOT EXISTS `showrooms` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `name` VARCHAR(255) NOT NULL,
    `location` VARCHAR(255) NOT NULL,
    INDEX `idx_showroom_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Table: users
-- Stores login info for all users (Common Users and Owners).
-- Assumes ONE owner per showroom.
CREATE TABLE IF NOT EXISTS `users` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `username` VARCHAR(100) NOT NULL UNIQUE,
    `password` VARCHAR(255) NOT NULL, -- Will store encrypted (BCrypt) password
    `email` VARCHAR(100) NOT NULL UNIQUE,
    `role` ENUM('ROLE_USER', 'ROLE_OWNER') NOT NULL,
    `showroom_id` BIGINT NULL UNIQUE, -- An owner is linked to one showroom

    INDEX `idx_username` (`username`),
    INDEX `idx_email` (`email`),

    FOREIGN KEY (`showroom_id`) REFERENCES `showrooms`(`id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. Table: cars (MODIFIED)
-- Now includes a foreign key to 'showrooms'
CREATE TABLE IF NOT EXISTS `cars` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `brand` VARCHAR(100) NOT NULL,
    `model` VARCHAR(100) NOT NULL,
    `year` INT NOT NULL,
    `price` DECIMAL(12, 2) NOT NULL,
    `description` TEXT,
    `image_url` VARCHAR(2048),
    `showroom_id` BIGINT NOT NULL,     -- The car now BELONGS to a showroom

    INDEX `idx_brand_model` (`brand`, `model`),
    INDEX `idx_cars_showroom` (`showroom_id`),
    FOREIGN KEY (`showroom_id`) REFERENCES `showrooms`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. Table: car_specifications
CREATE TABLE IF NOT EXISTS `car_specifications` (
    `car_id` BIGINT NOT NULL,
    `specifications_key` VARCHAR(255) NOT NULL,
    `specifications` VARCHAR(255) NOT NULL,

    PRIMARY KEY (`car_id`, `specifications_key`),
    FOREIGN KEY (`car_id`) REFERENCES `cars`(`id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. Table: bookings (For Test Drives)
CREATE TABLE IF NOT EXISTS `bookings` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `user_name` VARCHAR(255) NOT NULL,
    `email` VARCHAR(255) NOT NULL,
    `phone` VARCHAR(20),
    `car_id` BIGINT NOT NULL,
    `date` DATETIME NOT NULL, -- The date of the appointment
    `booked_on` timestamp DEFAULT CURRENT_TIMESTAMP,

    INDEX `idx_booking_email` (`email`),
    INDEX `idx_booking_car_id` (`car_id`),
    FOREIGN KEY (`car_id`) REFERENCES `cars`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. Table: pre_bookings (For Pre-Orders)
CREATE TABLE IF NOT EXISTS `pre_bookings` (
    `id` BIGINT AUTO_INCREMENT PRIMARY KEY,
    `user_name` VARCHAR(255) NOT NULL,
    `email` VARCHAR(255) NOT NULL,
    `car_id` BIGINT NOT NULL,
    `payment_status` ENUM('PENDING', 'COMPLETED', 'FAILED') NOT NULL DEFAULT 'PENDING',
    `date` DATETIME NOT NULL, -- The date the pre-booking was made
    `booked_on` timestamp DEFAULT CURRENT_TIMESTAMP,

    INDEX `idx_prebooking_email` (`email`),
    INDEX `idx_prebooking_car_id` (`car_id`),
    FOREIGN KEY (`car_id`) REFERENCES `cars`(`id`) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --- INSERT UPGRADED SAMPLE DATA ---

-- 1. Create Showrooms
INSERT INTO `showrooms` (name, location) VALUES
('Prestige Motors', 'Mumbai'),
('FutureAuto', 'Delhi');

-- 2. Create Users
-- The password for all users is "password123"
-- This is the BCRYPT hash for "password123": $2a$10$3JSHqed8KE0ONBYnT6AZ2u5s8kT3Umg.DcOR0zBUMr/Af4tHT1d.O
INSERT INTO `users` (username, password, email, role, showroom_id) VALUES
('owner_mumbai', '$2a$10$3JSHqed8KE0ONBYnT6AZ2u5s8kT3Umg.DcOR0zBUMr/Af4tHT1d.O', 'owner.mumbai@example.com', 'ROLE_OWNER', 1),
('owner_delhi', '$2a$10$3JSHqed8KE0ONBYnT6AZ2u5s8kT3Umg.DcOR0zBUMr/Af4tHT1d.O', 'owner.delhi@example.com', 'ROLE_OWNER', 2),
('common_user', '$2a$10$3JSHqed8KE0ONBYnT6AZ2u5s8kT3Umg.DcOR0zBUMr/Af4tHT1d.O', 'user@example.com', 'ROLE_USER', NULL);

-- 3. Insert Cars for Showroom 1 (Prestige Motors, Mumbai)
INSERT INTO `cars` (`brand`, `model`, `price`, `description`, `image_url`, `year`, `showroom_id`) VALUES
('Tesla', 'Model S', 74990.00, 'A full-size all-electric luxury sedan.', '	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSkqJfWQeD8z-V1OjieTgkIYn_MyTe1fBf8Fg&s', 2024, 1),
('Rivian', 'R1S', 78000.00, 'A powerful all-electric, three-row SUV.', 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD…sSdZve4toqbmzvMdAIGhAgck6SpEMC5x5DvknxzJJJKhH/9k=', 2024, 1),
('Tesla', 'Model 3', 38990.00, 'A best-selling all-electric sedan with a minimalist interior and long-range capability.', 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD…rKytKJs3dxKlQM0gC1kiOVxUaVgWVmnlFeVlSopaRTk3tn//Z', 2024, 1),
('Audi', 'A4', 41900.00, 'A luxury compact sedan with a high-tech interior and standard all-wheel drive.', 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD…bIZmE8zExux8PnEprWgcPvioolsJAj6KHnWNrRyKtCo//2Q==', 2024, 1),
('BMW', '3 Series', 44500.00, 'The benchmark for sport sedans, blending performance with luxury.', '	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQ5C1qb4d8NySH6ihw82AObr1CAqj3_sg830w&s', 2024, 1);

-- 4. Insert Cars for Showroom 2 (FutureAuto, Delhi)
INSERT INTO `cars` (`brand`, `model`, `price`, `description`, `image_url`, `year`, `showroom_id`) VALUES
('Ford', 'Mustang Mach-E', 46995.00, 'An electric compact crossover SUV.', '	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTVolG_-LNPMqA4zF6aUh9200i6K1Wt0KI8Ig&s', 2024, 2),
('Toyota', 'Camry', 30100.00, 'A popular and reliable midsize sedan, now available primarily as a hybrid.', 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSG5LUeqzJiuWy9H1htWEk2T1qK16wwtBx46Q&s', 2025, 2),
('Honda', 'Accord', 29045.00, 'A top-rated midsize sedan known for its enjoyable road manners and fuel economy.', '	https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcS5MsKKLUNv-c1AEUr76PK1lcsk77X9T6SePg&s', 2024, 2),
('Ford', 'Mustang', 33515.00, 'An iconic American muscle car with a new generation, offering V8 or EcoBoost power.', 'data:image/jpeg;base64,/9j/4AAQSkZJRgABAQAAAQABAAD…AWaPniigLNFmjxQGzRs0UUBZos8UUBi8gWiigRzRRRQP/2Q==', 2024, 2);

-- 5. Insert Specs (car_id corresponds to the IDs above: 1-10)
INSERT INTO `car_specifications` (`car_id`, `specifications_key`, `specifications`) VALUES
(1, 'Range', '405 miles'),
(1, '0-60 mph', '3.1 seconds'),
(1, 'Drivetrain', 'AWD'),
(2, 'Range', '321 miles'),
(2, '0-60 mph', '3.0 seconds'),
(2, 'Seating', '7'),
(3, 'Engine', 'Electric Motor (RWD)'),
(3, 'Range', '272 miles (EPA est.)'),
(3, '0-60 mph', '5.8 seconds'),
(4, 'Engine', '2.0L 4-Cylinder Turbo (40 TFSI)'),
(4, 'Horsepower', '201 hp'),
(4, 'Drivetrain', 'Quattro AWD'),
(5, 'Engine', '2.0L 4-Cylinder Turbo (330i)'),
(5, 'Horsepower', '255 hp'),
(5, 'Transmission', '8-speed automatic'),
(6, 'Range', '310 miles'),
(6, '0-60 mph', '5.1 seconds'),
(6, 'Cargo', '59.7 cu ft'),
(7, 'Engine', '2.5L 4-Cylinder Hybrid'),
(7, 'Horsepower', '225 hp (FWD)'),
(7, 'Transmission', 'ECVT'),
(8, 'Engine', '1.5L Turbo 4-Cylinder'),
(8, 'Horsepower', '192 hp'),
(8, 'Transmission', 'CVT'),
(9, 'Engine', '2.3L EcoBoost 4-Cylinder'),
(9, 'Horsepower', '315 hp'),
(9, 'Transmission', '10-speed automatic');


-- Quick verification queries
SELECT * FROM cars;
SELECT * FROM users;
SELECT * FROM showrooms;
SELECT * FROM car_specifications;
select * from pre_bookings;
select * from bookings;

truncate table bookings;
truncate table pre_bookings;