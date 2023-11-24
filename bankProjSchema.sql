-- CREATE DB AND MAKE IT DEFAULT
CREATE SCHEMA `bankschema`;
USE `bankschema`;

/*** Import additional tables needed for inserts later ***/

-- Run the python csv_generators and have them create the csv files
-- Left click bank schema -> Table Data Import Wizard -> choose file path -> create new table in current schema -> import data
-- user_data and transactions tables that will be used for inserts into user and transaction_history tables

-- In this SQL file, write (and comment!) the schema of your database, including the CREATE TABLE, CREATE INDEX, CREATE VIEW, etc. statements that compose it

/*** CREATING TABLES ***/

-- user table that stores information on the user
CREATE TABLE `user`(
    `id` SMALLINT UNSIGNED AUTO_INCREMENT,
    `username` VARCHAR(32) NOT NULL,
    `first_name` TINYTEXT,
    `last_name` TINYTEXT,
    `password` VARCHAR(32) NOT NULL,
    `type` ENUM('personal', 'business') NOT NULL,
    `email` VARCHAR(320) NOT NULL,
    `age` TINYINT,
    `date_of_birth` DATE,
    `state` CHAR(2),
    `phone_number` VARCHAR(30),
    `pin` SMALLINT,
    PRIMARY KEY(`id`),
    CHECK (
        (`type` = 'personal' AND (`age` IS NOT NULL OR `date_of_birth` IS NOT NULL))
        OR
        (`type` = 'business')
    )
);


-- account balance table
CREATE TABLE `account_balance`(
    `user_id` SMALLINT UNSIGNED,
    `username` VARCHAR(32) NOT NULL,
    `current_balance` DECIMAL(10,2) SIGNED DEFAULT 0,
    PRIMARY KEY(`user_id`),
    FOREIGN KEY(`user_id`) REFERENCES `user`(`id`)
);

-- connections between users table
CREATE TABLE `user_connections` (
    `connection_id` INT UNSIGNED AUTO_INCREMENT,
    `user_id` SMALLINT UNSIGNED NOT NULL,
    `username` VARCHAR(32) NOT NULL,
    `friend_id` SMALLINT UNSIGNED NOT NULL,
    `friend` VARCHAR(32) NOT NULL,
    PRIMARY KEY (`connection_id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
    FOREIGN KEY (`friend_id`) REFERENCES `user` (`id`)
);

-- transaction history table
CREATE TABLE `transaction_history` (
    `transaction_id` INT UNSIGNED AUTO_INCREMENT,
    `user_id` SMALLINT UNSIGNED NOT NULL,
    `username` VARCHAR(32) NOT NULL,
    `transaction_amount` DECIMAL(10,2) SIGNED NOT NULL,
    `type` ENUM('deposit', 'withdrawal', 'received', 'sent') NOT NULL,
    `user_2` VARCHAR(32) DEFAULT NULL,
    `user_id_2` SMALLINT UNSIGNED DEFAULT NULL,
    PRIMARY KEY (`transaction_id`),
    FOREIGN KEY (`user_id`) REFERENCES `user` (`id`),
    FOREIGN KEY (`user_id_2`) REFERENCES `user` (`id`)
);




/*** INDEXES ***/
-- Index on the `type` column to speed up the first query
CREATE INDEX idx_user_type ON `user`(`type`);

-- Index on the `id` column for faster joins and lookups
CREATE INDEX idx_user_id ON `user`(`id`);

-- Index on the `type` column for faster filtering in the second query
CREATE INDEX idx_transaction_type ON `transaction_history`(`type`);

-- Index on the `user_id` and `user_id_2` columns for faster joins
CREATE INDEX idx_transaction_user_ids ON `transaction_history`(`user_id`, `user_id_2`);

-- Index on the `user_id` and `friend_id` columns for faster joins
CREATE INDEX idx_connections_user_ids ON `user_connections`(`user_id`, `friend_id`);




/*** Insertion of data into user and account_balance tables ***/

--  insertion into user table
INSERT INTO `user` (
    `username`, 
    `first_name`, 
    `last_name`, 
    `password`, 
    `type`, 
    `email`, 
    `age`, 
    `date_of_birth`, 
    `state`, 
    `phone_number`, 
    `pin`
) 
SELECT 
    `username`, 
    `first_name`, 
    `last_name`, 
    `password`, 
    `type`, 
    `email`, 
    `age`, 
    `date_of_birth`, 
    `state`, 
    `phone_number`, 
    `pin`
FROM `user_data`;


-- Insertions into account_balance table
INSERT INTO `account_balance` (`user_id`,`username`)
SELECT `id`, `username`
FROM `user`;


/*** TRIGGERS  ***/

-- TRIGGER FOR UPDATING THE BALANCE IN THE account_balance table
-- need delimiter to allow the transaction to work

DELIMITER //

CREATE TRIGGER `update_balance_trigger`
AFTER INSERT ON `transaction_history`
FOR EACH ROW
BEGIN
    DECLARE new_balance DECIMAL(10,2);

    -- Update user's balance based on transaction type
    IF NEW.type = 'deposit' OR NEW.type = 'received' THEN
        SET new_balance = (SELECT `current_balance` + NEW.`transaction_amount` FROM `account_balance` WHERE `user_id` = NEW.`user_id`);
    ELSEIF NEW.type = 'withdrawal' OR NEW.type = 'sent' THEN
        SET new_balance = (SELECT `current_balance` - NEW.`transaction_amount` FROM `account_balance` WHERE `user_id` = NEW.`user_id`);
    END IF;

    -- Update the account_balance table
    UPDATE `account_balance`
    SET `current_balance` = new_balance
    WHERE `user_id` = NEW.`user_id`;
END;
//

DELIMITER ;

/*** Insertions for the user_connections and transaction_history table ***/

-- Insert random connections between users
-- ** If you lose connection, re-connect and the rows will be there **
INSERT IGNORE INTO `user_connections` (`user_id`, `username`, `friend_id`, `friend`)
SELECT
    u1.`id` AS `user_id`,
    u1.`username`,
    u2.`id` AS `friend_id`,
    u2.`username` AS `friend`
FROM
    `user` u1
JOIN
    `user` u2 ON u1.`id` < u2.`id`  -- Ensure that user_id is smaller than friend_id to avoid duplicates
ORDER BY
    RAND()
LIMIT
    1000;  -- Adjust the limit as desired
    
    

-- Insert data from transactions table into transaction_history
INSERT INTO `transaction_history` (`user_id`, `username`, `transaction_amount`, `type`, `user_2`, `user_id_2`)
SELECT `user_id`, `username`, `transaction_amount`, `type`, `user_2`, `user_id_2`
FROM 
`transactions`;







