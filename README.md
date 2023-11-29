# Design Document

## Scope

### Purpose of the Database:
The database aims to manage a banking system, providing functionality for user account management, transactions, and user connections.

### Included in Scope:
- Users (personal and business)
- Account balances
- User connections
- Transaction history

### Outside the Scope:
- Detailed user preferences beyond basic information
- Complex financial instruments (e.g., loans, investments)

## Functional Requirements

### User Actions:
Users can perform:
- Account creation and management
- View transaction history
- Connect with other users
- Make deposits, withdrawals, and transfers

### Beyond Scope:
- Advanced financial analytics
- Investment portfolio management

## Representation

### Entities

#### 1. User Entity:
- **Attributes:**
  - `id` (SMALLINT UNSIGNED)
  - `username` (VARCHAR(32))
  - `first_name` (TINYTEXT)
  - `last_name` (TINYTEXT)
  - `password` (VARCHAR(32))
  - `type` (ENUM('personal', 'business'))
  - `email` (VARCHAR(320))
  - `age` (TINYINT)
  - `date_of_birth` (DATE)
  - `state` (CHAR(2))
  - `phone_number` (VARCHAR(30))
  - `pin` (SMALLINT)
- **Types:**
  - Chose types based on data nature (e.g., VARCHAR for text, DECIMAL for financial amounts).
- **Constraints:**
  - `CHECK` constraint ensures personal users have either age or date of birth.

#### 2. Account Balance Entity:
- **Attributes:**
  - `user_id` (SMALLINT UNSIGNED)
  - `username` (VARCHAR(32))
  - `current_balance` (DECIMAL(10,2))
- **Types:**
  - Chose types based on data nature. `DECIMAL` for financial amounts.
- **Constraints:**
  - None, as the focus is on storing account balance data.

#### 3. User Connections Entity:
- **Attributes:**
  - `connection_id` (INT UNSIGNED)
  - `user_id` (SMALLINT UNSIGNED)
  - `username` (VARCHAR(32))
  - `friend_id` (SMALLINT UNSIGNED)
  - `friend` (VARCHAR(32))
- **Types:**
  - Used standard integer types for IDs and VARCHAR for usernames.
- **Constraints:**
  - None beyond primary and foreign keys.

#### 4. Transaction History Entity:
- **Attributes:**
  - `transaction_id` (INT UNSIGNED)
  - `user_id` (SMALLINT UNSIGNED)
  - `username` (VARCHAR(32))
  - `transaction_amount` (DECIMAL(10,2))
  - `type` (ENUM('deposit', 'withdrawal', 'received', 'sent'))
  - `user_2` (VARCHAR(32))
  - `user_id_2` (SMALLINT UNSIGNED)
- **Types:**
  - Chose types based on data nature. `DECIMAL` for financial amounts, ENUM for transaction types.
- **Constraints:**
  - Foreign keys establish relationships, and a trigger ensures the account balance is updated after each transaction.

### Relationships

- See attached Entity Relationship Diagram (ERD) for visual representation.
- ![image](https://github.com/Adamb0lt/Banking_DB/assets/122646712/42afcfc7-b544-406e-9df1-62e1dc9be1fa)


## Optimizations

### Implemented Optimizations:
- Indexes on frequently used columns (`type`, `user_id`, `user_id_2`, `friend_id`) to enhance query performance.

### Reasons for Optimizations:
- Improves efficiency for common queries involving joins and filtering.

## Additional Files

### bankProj_csv_generator

```python
# Code to generate random user data for the user table
# ...

# Adjust the number of rows and output filename as needed
