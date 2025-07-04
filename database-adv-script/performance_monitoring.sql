USE alx_airbnb;

-- ============================================================================
-- PERFORMANCE MONITORING AND OPTIMIZATION SCRIPT
-- ============================================================================

-- Enable profiling for detailed performance analysis
SET profiling = 1;

-- ============================================================================
-- FREQUENTLY USED QUERIES - PERFORMANCE ANALYSIS
-- ============================================================================

-- Query 1: User Booking History (Frequently used by users)
-- This query is commonly used to show users their booking history
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    p.p_name,
    p.location
FROM booking b
INNER JOIN property p ON b.property_id = p.property_id
WHERE b.user_id = 1
ORDER BY b.start_date DESC;

-- Analyze Query 1 performance
EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    p.p_name,
    p.location
FROM booking b
INNER JOIN property p ON b.property_id = p.property_id
WHERE b.user_id = 1
ORDER BY b.start_date DESC;

-- Query 2: Property Availability Check (Critical for booking process)
-- This query checks if a property is available for specific dates
SELECT 
    p.property_id,
    p.p_name,
    p.price_per_night,
    COUNT(b.booking_id) as conflicting_bookings
FROM property p
LEFT JOIN booking b ON p.property_id = b.property_id
    AND b.status IN ('confirmed', 'pending')
    AND (
        (b.start_date <= '2024-06-15' AND b.end_date >= '2024-06-10')
        OR (b.start_date <= '2024-06-20' AND b.end_date >= '2024-06-15')
    )
WHERE p.property_id = 1
GROUP BY p.property_id, p.p_name, p.price_per_night;

-- Analyze Query 2 performance
EXPLAIN ANALYZE
SELECT 
    p.property_id,
    p.p_name,
    p.price_per_night,
    COUNT(b.booking_id) as conflicting_bookings
FROM property p
LEFT JOIN booking b ON p.property_id = b.property_id
    AND b.status IN ('confirmed', 'pending')
    AND (
        (b.start_date <= '2024-06-15' AND b.end_date >= '2024-06-10')
        OR (b.start_date <= '2024-06-20' AND b.end_date >= '2024-06-15')
    )
WHERE p.property_id = 1
GROUP BY p.property_id, p.p_name, p.price_per_night;

-- Query 3: Revenue Analysis by Month (Business Intelligence)
-- This query is used for financial reporting and analysis
SELECT 
    YEAR(b.start_date) as year,
    MONTH(b.start_date) as month,
    COUNT(*) as total_bookings,
    SUM(b.total_price) as total_revenue,
    AVG(b.total_price) as avg_booking_value,
    COUNT(CASE WHEN b.status = 'completed' THEN 1 END) as completed_bookings
FROM booking b
WHERE b.start_date >= '2024-01-01' AND b.start_date <= '2024-12-31'
GROUP BY YEAR(b.start_date), MONTH(b.start_date)
ORDER BY year, month;

-- Analyze Query 3 performance
EXPLAIN ANALYZE
SELECT 
    YEAR(b.start_date) as year,
    MONTH(b.start_date) as month,
    COUNT(*) as total_bookings,
    SUM(b.total_price) as total_revenue,
    AVG(b.total_price) as avg_booking_value,
    COUNT(CASE WHEN b.status = 'completed' THEN 1 END) as completed_bookings
FROM booking b
WHERE b.start_date >= '2024-01-01' AND b.start_date <= '2024-12-31'
GROUP BY YEAR(b.start_date), MONTH(b.start_date)
ORDER BY year, month;

-- Query 4: Popular Properties (Marketing and Analytics)
-- This query identifies the most popular properties
SELECT 
    p.property_id,
    p.p_name,
    p.location,
    COUNT(b.booking_id) as booking_count,
    AVG(b.total_price) as avg_price,
    SUM(b.total_price) as total_revenue
FROM property p
LEFT JOIN booking b ON p.property_id = b.property_id
    AND b.status = 'completed'
WHERE b.start_date >= '2024-01-01'
GROUP BY p.property_id, p.p_name, p.location
ORDER BY booking_count DESC
LIMIT 10;

-- Analyze Query 4 performance
EXPLAIN ANALYZE
SELECT 
    p.property_id,
    p.p_name,
    p.location,
    COUNT(b.booking_id) as booking_count,
    AVG(b.total_price) as avg_price,
    SUM(b.total_price) as total_revenue
FROM property p
LEFT JOIN booking b ON p.property_id = b.property_id
    AND b.status = 'completed'
WHERE b.start_date >= '2024-01-01'
GROUP BY p.property_id, p.p_name, p.location
ORDER BY booking_count DESC
LIMIT 10;

-- Query 5: User Activity Analysis (User Management)
-- This query analyzes user booking patterns
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(b.booking_id) as total_bookings,
    SUM(b.total_price) as total_spent,
    AVG(b.total_price) as avg_booking_value,
    MAX(b.created_at) as last_booking_date
FROM user u
LEFT JOIN booking b ON u.user_id = b.user_id
    AND b.status = 'completed'
GROUP BY u.user_id, u.first_name, u.last_name
HAVING total_bookings > 0
ORDER BY total_spent DESC
LIMIT 20;

-- Analyze Query 5 performance
EXPLAIN ANALYZE
SELECT 
    u.user_id,
    u.first_name,
    u.last_name,
    COUNT(b.booking_id) as total_bookings,
    SUM(b.total_price) as total_spent,
    AVG(b.total_price) as avg_booking_value,
    MAX(b.created_at) as last_booking_date
FROM user u
LEFT JOIN booking b ON u.user_id = b.user_id
    AND b.status = 'completed'
GROUP BY u.user_id, u.first_name, u.last_name
HAVING total_bookings > 0
ORDER BY total_spent DESC
LIMIT 20;

-- ============================================================================
-- SHOW PROFILES - PERFORMANCE ANALYSIS
-- ============================================================================

-- Show all profiles to analyze query performance
SHOW PROFILES;

-- Show detailed profile for the last query
SHOW PROFILE FOR QUERY 1;

-- Show CPU and I/O profile
SHOW PROFILE CPU, BLOCK IO FOR QUERY 1;

-- ============================================================================
-- INDEX ANALYSIS AND OPTIMIZATION
-- ============================================================================

-- Check existing indexes
SHOW INDEX FROM booking;
SHOW INDEX FROM property;
SHOW INDEX FROM user;

-- Analyze table statistics
ANALYZE TABLE booking;
ANALYZE TABLE property;
ANALYZE TABLE user;

-- ============================================================================
-- IDENTIFIED BOTTLENECKS AND OPTIMIZATION SUGGESTIONS
-- ============================================================================

-- Bottleneck 1: Missing composite index for user booking history
-- Problem: Query 1 performs full table scan on booking table
-- Solution: Create composite index on (user_id, start_date)
CREATE INDEX idx_booking_user_date ON booking(user_id, start_date DESC);

-- Bottleneck 2: Missing index for date range queries
-- Problem: Query 3 performs full table scan for date filtering
-- Solution: Create index on start_date
CREATE INDEX idx_booking_start_date ON booking(start_date);

-- Bottleneck 3: Missing composite index for property availability
-- Problem: Query 2 has complex date range conditions
-- Solution: Create composite index for availability checks
CREATE INDEX idx_booking_property_status_dates ON booking(property_id, status, start_date, end_date);

-- Bottleneck 4: Missing index for revenue analysis
-- Problem: Query 3 needs efficient grouping and aggregation
-- Solution: Create composite index for date-based aggregations
CREATE INDEX idx_booking_date_status_price ON booking(start_date, status, total_price);

-- Bottleneck 5: Missing index for user activity analysis
-- Problem: Query 5 needs efficient user-based aggregations
-- Solution: Create composite index for user analysis
CREATE INDEX idx_booking_user_status_price ON booking(user_id, status, total_price, created_at);

-- ============================================================================
-- OPTIMIZED QUERIES - AFTER INDEX IMPLEMENTATION
-- ============================================================================

-- Optimized Query 1: User Booking History
-- Expected improvement: 80-90% faster due to composite index
EXPLAIN ANALYZE
SELECT 
    b.booking_id,
    b.start_date,
    b.end_date,
    b.total_price,
    b.status,
    p.p_name,
    p.location
FROM booking b
INNER JOIN property p ON b.property_id = p.property_id
WHERE b.user_id = 1
ORDER BY b.start_date DESC;

-- Optimized Query 2: Property Availability Check
-- Expected improvement: 70-85% faster due to composite index
EXPLAIN ANALYZE
SELECT 
    p.property_id,
    p.p_name,
    p.price_per_night,
    COUNT(b.booking_id) as conflicting_bookings
FROM property p
LEFT JOIN booking b ON p.property_id = b.property_id
    AND b.status IN ('confirmed', 'pending')
    AND (
        (b.start_date <= '2024-06-15' AND b.end_date >= '2024-06-10')
        OR (b.start_date <= '2024-06-20' AND b.end_date >= '2024-06-15')
    )
WHERE p.property_id = 1
GROUP BY p.property_id, p.p_name, p.price_per_night;

-- Optimized Query 3: Revenue Analysis
-- Expected improvement: 60-75% faster due to composite index
EXPLAIN ANALYZE
SELECT 
    YEAR(b.start_date) as year,
    MONTH(b.start_date) as month,
    COUNT(*) as total_bookings,
    SUM(b.total_price) as total_revenue,
    AVG(b.total_price) as avg_booking_value,
    COUNT(CASE WHEN b.status = 'completed' THEN 1 END) as completed_bookings
FROM booking b
WHERE b.start_date >= '2024-01-01' AND b.start_date <= '2024-12-31'
GROUP BY YEAR(b.start_date), MONTH(b.start_date)
ORDER BY year, month;

-- ============================================================================
-- SCHEMA OPTIMIZATION SUGGESTIONS
-- ============================================================================

-- Suggestion 1: Add covering indexes for frequently accessed columns
-- This reduces the need to access the main table for common queries
CREATE INDEX idx_booking_covering ON booking(booking_id, user_id, property_id, start_date, end_date, total_price, status);

-- Suggestion 2: Partition the booking table by date (if not already done)
-- This improves performance for date-range queries
-- (See partitioning.sql for implementation)

-- Suggestion 3: Add computed columns for frequently calculated values
-- Example: Add booking_duration column to avoid calculating it repeatedly
ALTER TABLE booking ADD COLUMN booking_duration INT AS (DATEDIFF(end_date, start_date)) STORED;
CREATE INDEX idx_booking_duration ON booking(booking_duration);

-- ============================================================================
-- PERFORMANCE MONITORING QUERIES
-- ============================================================================

-- Monitor index usage
SELECT 
    TABLE_NAME,
    INDEX_NAME,
    CARDINALITY,
    SUB_PART,
    PACKED,
    NULLABLE,
    INDEX_TYPE
FROM INFORMATION_SCHEMA.STATISTICS 
WHERE TABLE_SCHEMA = 'alx_airbnb' 
AND TABLE_NAME = 'booking'
ORDER BY INDEX_NAME;

-- Monitor table sizes
SELECT 
    TABLE_NAME,
    ROUND(((DATA_LENGTH + INDEX_LENGTH) / 1024 / 1024), 2) AS 'Size (MB)',
    TABLE_ROWS
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_SCHEMA = 'alx_airbnb'
ORDER BY (DATA_LENGTH + INDEX_LENGTH) DESC;

-- Monitor slow queries (if slow query log is enabled)
-- SHOW VARIABLES LIKE 'slow_query_log';
-- SHOW VARIABLES LIKE 'long_query_time';

-- ============================================================================
-- FINAL PERFORMANCE COMPARISON
-- ============================================================================

-- Show final profiles after optimization
SHOW PROFILES;

-- Compare execution times
SELECT 
    QUERY_ID,
    DURATION,
    QUERY
FROM INFORMATION_SCHEMA.PROFILING 
WHERE QUERY_ID IN (1, 2, 3, 4, 5)
ORDER BY QUERY_ID; 