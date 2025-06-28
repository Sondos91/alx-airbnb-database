# Database Normalization Steps to Achieve 3NF

## 1. Initial Schema Review
The initial schema included the following tables: User, Property, Booking, Payment, Review, and Message. While the schema was generally well-structured, some columns used ENUMs or stored compound data, which could lead to inflexibility and potential redundancy as the application grows.

## 2. Normalization Principles
- **1NF:** All tables have atomic values (no repeating groups).
- **2NF:** All non-key attributes are fully functionally dependent on the primary key.
- **3NF:** No transitive dependencies; all attributes are only dependent on the primary key.

## 3. Identified Issues
- **User Table:** The `user_role` column used an ENUM, which is inflexible if roles expand.
- **Property Table:** The `location` column stored the full address as a single string, which is not ideal for querying or reusing location data.
- **Payment Table:** The `payment_method` column used an ENUM, which is inflexible if payment methods expand.

## 4. Normalization Steps
### A. User Roles
- **Before:** `user_role ENUM('guest', 'host', 'admin')`
- **After:** Create a `Role` table and reference it in the `User` table with a foreign key.

### B. Property Location
- **Before:** `location VARCHAR(255)` in `Property`
- **After:** Create a `Location` table (address, city, state, country) and reference it in the `Property` table with a foreign key.

### C. Payment Methods
- **Before:** `payment_method ENUM('credit_card', 'paypal', 'stripe')` in `Payment`
- **After:** Create a `PaymentMethod` table and reference it in the `Payment` table with a foreign key.

## 5. Proposed New Tables
```sql
-- Role Table
CREATE TABLE Role (
    role_id INT PRIMARY KEY AUTO_INCREMENT,
    role_name VARCHAR(50) NOT NULL UNIQUE
);

-- Location Table
CREATE TABLE Location (
    location_id INT PRIMARY KEY AUTO_INCREMENT,
    address VARCHAR(255),
    city VARCHAR(100),
    state VARCHAR(100),
    country VARCHAR(100)
);

-- PaymentMethod Table
CREATE TABLE PaymentMethod (
    method_id INT PRIMARY KEY AUTO_INCREMENT,
    method_name VARCHAR(50) NOT NULL UNIQUE
);
```

## 6. Schema Adjustments
- In `User`, replace `user_role` with `role_id` (FK to `Role`).
- In `Property`, replace `location` with `location_id` (FK to `Location`).
- In `Payment`, replace `payment_method` with `method_id` (FK to `PaymentMethod`).

## 7. Benefits
- **Flexibility:** Adding new roles, locations, or payment methods does not require schema changes.
- **Data Integrity:** Reduces redundancy and enforces referential integrity.
- **Query Efficiency:** Easier to query and manage related data.
