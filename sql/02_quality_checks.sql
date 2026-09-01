-- Row counts for the six source tables
SELECT 'orders' AS table_name, count(*) FROM orders
UNION ALL
SELECT 'order_items' AS table_name, count(*) FROM order_items
UNION ALL
SELECT 'customers' AS table_name , count(*) FROM customers
UNION ALL
SELECT 'products' AS table_name, count(*) FROM products
UNION ALL
SELECT 'reviews' AS table_name, count(*) FROM reviews
UNION ALL
SELECT 'category_translation' AS table_name, count(*) FROM category_translation
ORDER BY table_name;

-- Duplicate order Ids: this query should return zero rows
SELECT order_id, count(*) AS row_count
FROM orders
GROUP BY order_id
HAVING count(*) > 1
ORDER BY row_count DESC;

-- Missing important order fields
SELECT
    SUM(CASE WHEN order_id IS NULL OR TRIM(order_id) = '' THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN customer_id IS NULL OR TRIM(customer_id) = '' THEN 1 ELSE 0 END) AS missing_customer_id,
    SUM(CASE WHEN order_purchase_timestamp IS NULL
    OR TRIM(order_purchase_timestamp) = '' THEN 1 ELSE 0 END) AS missing_purchase_date
FROM orders;

-- Order statuses and counts
SELECT order_status, count(*) AS row_count
FROM orders
GROUP BY order_status
ORDER BY row_count DESC;

-- Purchase date range
SELECT 
    MIN(TRY_CAST(order_purchase_timestamp AS DATE)) AS first_purchase,
    MAX(TRY_CAST(order_purchase_timestamp AS DATE)) AS last_purchase
FROM orders;

-- Order items tat do not match an order: should be zero
SELECT COUNT(*) AS unmatched_order_items
FROM order_items AS i
LEFT JOIN orders AS o ON i.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Customers referenced by orders but missing from the customer table: should be zero
SELECT COUNT(*) AS unmatched_customers
FROM orders AS o
LEFT JOIN customers AS c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;