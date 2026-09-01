CREATE OR REPLACE TABLE mart_sales AS
SELECT 
    i.order_id,
    TRY_CAST(i.order_item_id AS INT) AS order_item_id,
    TRY_CAST(o.order_purchase_timestamp AS TIMESTAMP) AS order_purchase_timestamp,
    CAST(TRY_CAST(o.order_purchase_timestamp AS TIMESTAMP) AS DATE) AS purchase_date,
    o.order_status,
    c.customer_unique_id,
    UPPER(c.customer_state) AS customer_state,
    i.product_id,
    COALESCE(
        t.product_category_name_english,
        p.product_category_name,
        'Unknown'
    ) AS product_category,
    TRY_CAST(i.price AS DOUBLE) AS price,
    TRY_CAST(i.freight_value AS DOUBLE) AS freight_value
FROM order_items AS i
INNER JOIN orders AS o ON i.order_id = o.order_id
LEFT JOIN customers AS c ON o.customer_id = c.customer_id
LEFT JOIN products AS p ON i.product_id = p.product_id
LEFT JOIN category_translation AS t ON p.product_category_name = t.product_category_name;