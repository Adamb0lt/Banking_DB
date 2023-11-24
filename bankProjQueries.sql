/*** Queries for analysis and business purposes ***/

-- Simple query to retrieve basic user information
CREATE VIEW `personal_accounts` AS
SELECT `id`, `username`, `first_name`, `last_name`, `email`
FROM `user`
WHERE `type` = 'personal';

-- Query with joins to retrieve transaction history with user details
SELECT th.`transaction_id`, th.`username` AS `sender_username`, u.`email` AS `sender_email`,
       th.`transaction_amount`, th.`type`, th.`user_2` AS `receiver_username`
FROM `transaction_history` th
JOIN `user` u ON th.`user_id` = u.`id`
WHERE th.`type` IN ('sent', 'received');

-- Query with joins and CTE to retrieve user connections and their total transaction amounts
WITH UserConnectionsCTE AS (
    SELECT uc.`user_id`, uc.`username`, uc.`friend_id`, uc.`friend`
    FROM `user_connections` uc
    JOIN `user` u ON uc.`user_id` = u.`id`
)
SELECT uccte.`username` AS `user`, uccte.`friend` AS `connection`, 
       SUM(th.`transaction_amount`) AS `total_transaction_amount`
FROM UserConnectionsCTE uccte
LEFT JOIN `transaction_history` th ON uccte.`user_id` = th.`user_id`
GROUP BY uccte.`username`, uccte.`friend`
ORDER BY `total_transaction_amount` DESC;


