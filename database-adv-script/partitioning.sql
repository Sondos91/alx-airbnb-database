USE alx_airbnb;

-- ============================================================================
-- TABLE PARTITIONING FOR PERFORMANCE OPTIMIZATION
-- ============================================================================

-- Step 1: Create a partitioned version of the booking table
-- Partition by date range (monthly partitions for better performance)

-- First, let's check if we need to backup existing data
-- CREATE TABLE booking_backup AS SELECT * FROM booking;

-- Drop existing table if it exists (be careful in production!)
-- DROP TABLE IF EXISTS booking_partitioned;

-- Create partitioned booking table
CREATE TABLE booking_partitioned (
    booking_id INT PRIMARY KEY,
    user_id INT NOT NULL,
    property_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    status ENUM('pending', 'confirmed', 'cancelled', 'completed') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_user_id (user_id),
    INDEX idx_property_id (property_id),
    INDEX idx_start_date (start_date),
    INDEX idx_status (status)
) PARTITION BY RANGE (YEAR(start_date) * 100 + MONTH(start_date)) (
    PARTITION p202301 VALUES LESS THAN (202302),
    PARTITION p202302 VALUES LESS THAN (202303),
    PARTITION p202303 VALUES LESS THAN (202304),
    PARTITION p202304 VALUES LESS THAN (202305),
    PARTITION p202305 VALUES LESS THAN (202306),
    PARTITION p202306 VALUES LESS THAN (202307),
    PARTITION p202307 VALUES LESS THAN (202308),
    PARTITION p202308 VALUES LESS THAN (202309),
    PARTITION p202309 VALUES LESS THAN (202310),
    PARTITION p202310 VALUES LESS THAN (202311),
    PARTITION p202311 VALUES LESS THAN (202312),
    PARTITION p202312 VALUES LESS THAN (202401),
    PARTITION p202401 VALUES LESS THAN (202402),
    PARTITION p202402 VALUES LESS THAN (202403),
    PARTITION p202403 VALUES LESS THAN (202404),
    PARTITION p202404 VALUES LESS THAN (202405),
    PARTITION p202405 VALUES LESS THAN (202406),
    PARTITION p202406 VALUES LESS THAN (202407),
    PARTITION p202407 VALUES LESS THAN (202408),
    PARTITION p202408 VALUES LESS THAN (202409),
    PARTITION p202409 VALUES LESS THAN (202410),
    PARTITION p202410 VALUES LESS THAN (202411),
    PARTITION p202411 VALUES LESS THAN (202412),
    PARTITION p202412 VALUES LESS THAN (202501),
    PARTITION p_future VALUES LESS THAN MAXVALUE
);

-- Insert data from existing booking table (if exists)
-- INSERT INTO booking_partitioned SELECT * FROM booking;

-- ============================================================================
-- PERFORMANCE TESTS FOR PARTITIONED TABLE
-- ============================================================================

-- Test 1: Query bookings by specific date range (Before Partitioning)
-- This query would scan the entire table
EXPLAIN ANALYZE
SELECT 
    booking_id,
    user_id,
    property_id,
    start_date,
    end_date,
    total_price,
    status
FROM booking
WHERE start_date >= '2024-01-01' AND start_date <= '2024-03-31'
ORDER BY start_date;

-- Test 2: Query bookings by specific date range (After Partitioning)
-- This query will only scan relevant partitions
EXPLAIN ANALYZE
SELECT 
    booking_id,
    user_id,
    property_id,
    start_date,
    end_date,
    total_price,
    status
FROM booking_partitioned
WHERE start_date >= '2024-01-01' AND start_date <= '2024-03-31'
ORDER BY start_date;

-- Test 3: Query bookings by month (Before Partitioning)
EXPLAIN ANALYZE
SELECT 
    COUNT(*) as total_bookings,
    SUM(total_price) as total_revenue,
    AVG(total_price) as avg_price
FROM booking
WHERE start_date >= '2024-02-01' AND start_date < '2024-03-01';

-- Test 4: Query bookings by month (After Partitioning)
EXPLAIN ANALYZE
SELECT 
    COUNT(*) as total_bookings,
    SUM(total_price) as total_revenue,
    AVG(total_price) as avg_price
FROM booking_partitioned
WHERE start_date >= '2024-02-01' AND start_date < '2024-03-01';

-- Test 5: Complex query with joins (Before Partitioning)
EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    u.first_name,
    u.last_name,
    p.p_name
FROM booking b
INNER JOIN user u ON b.user_id = u.user_id
INNER JOIN property p ON b.property_id = p.property_id
WHERE b.start_date >= '2024-01-01' AND b.start_date <= '2024-06-30'
ORDER BY b.start_date;

-- Test 6: Complex query with joins (After Partitioning)
EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    u.first_name,
    u.last_name,
    p.p_name
FROM booking_partitioned b
INNER JOIN user u ON b.user_id = u.user_id
INNER JOIN property p ON b.property_id = p.property_id
WHERE b.start_date >= '2024-01-01' AND b.start_date <= '2024-06-30'
ORDER BY b.start_date;

-- Test 7: Aggregation by date ranges (Before Partitioning)
EXPLAIN ANALYZE
SELECT 
    YEAR(start_date) as year,
    MONTH(start_date) as month,
    COUNT(*) as bookings_count,
    SUM(total_price) as revenue
FROM booking
WHERE start_date >= '2024-01-01' AND start_date <= '2024-12-31'
GROUP BY YEAR(start_date), MONTH(start_date)
ORDER BY year, month;

-- Test 8: Aggregation by date ranges (After Partitioning)
EXPLAIN ANALYZE
SELECT 
    YEAR(start_date) as year,
    MONTH(start_date) as month,
    COUNT(*) as bookings_count,
    SUM(total_price) as revenue
FROM booking_partitioned
WHERE start_date >= '2024-01-01' AND start_date <= '2024-12-31'
GROUP BY YEAR(start_date), MONTH(start_date)
ORDER BY year, month;

-- ============================================================================
-- PARTITION INFORMATION QUERIES
-- ============================================================================

-- Show partition information
SELECT 
    TABLE_NAME,
    PARTITION_NAME,
    PARTITION_ORDINAL_POSITION,
    PARTITION_METHOD,
    PARTITION_EXPRESSION,
    PARTITION_DESCRIPTION,
    TABLE_ROWS,
    AVG_ROW_LENGTH,
    DATA_LENGTH,
    MAX_DATA_LENGTH,
    INDEX_LENGTH,
    DATA_FREE
FROM INFORMATION_SCHEMA.PARTITIONS 
WHERE TABLE_SCHEMA = 'alx_airbnb' 
AND TABLE_NAME = 'booking_partitioned'
ORDER BY PARTITION_ORDINAL_POSITION;

-- Show which partitions are being used for a specific query
EXPLAIN PARTITIONS
SELECT * FROM booking_partitioned 
WHERE start_date >= '2024-02-01' AND start_date <= '2024-02-29';