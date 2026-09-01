CREATE OR REPLACE TABLE mart_orders AS
WITH order_totals AS (
    SELECT
        order_id,
        SUM(TRY_CAST(price AS DOUBLE)) AS order_value,
        SUM(TRY_CAST(freight_value AS DOUBLE)) AS freight_value,
        COUNT(*) AS item_count
    FROM order_items
    GROUP BY order_id
),
ranked_reviews AS (
    SELECT
        order_id,
        TRY_CAST(review_score AS INT) AS review_score,
        TRY_CAST(review_answer_timestamp as TIMESTAMP) AS review_answer_timestamp,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY TRY_CAST(review_answer_timestamp as TIMESTAMP) DESC NULLS LAST,
                review_id
        ) AS review_rank
    FROM reviews
),
latest_reviews AS (
    SELECT
        order_id,
        review_score,
    FROM ranked_reviews
    WHERE review_rank = 1
)
SELECT
    o.order_id,
    c.customer_unique_id,
    c.customer_city,
    UPPER(c.customer_state) AS customer_state,
    o.order_status,
    TRY_CAST(o.order_purchase_timestamp AS TIMESTAMP) AS order_purchase_timestamp,
    TRY_CAST(o.order_approved_at AS TIMESTAMP) AS order_approved_at,
    TRY_CAST(o.order_delivered_carrier_date AS TIMESTAMP) AS order_delivered_carrier_date,
    TRY_CAST(o.order_delivered_customer_date AS TIMESTAMP) AS order_delivered_customer_date,
    TRY_CAST(o.order_estimated_delivery_date AS TIMESTAMP) AS order_estimated_delivery_date,
    COALESCE(t.order_value, 0) AS order_value,
    COALESCE(t.freight_value, 0) AS freight_value,
    COALESCE(t.item_count, 0) AS item_count,
    CASE
        WHEN TRY_CAST(o.order_purchase_timestamp AS TIMESTAMP) IS NOT NULL
            AND TRY_CAST(o.order_delivered_customer_date AS TIMESTAMP) IS NOT NULL
        THEN date_diff(
            'day',
            TRY_CAST(o.order_purchase_timestamp AS TIMESTAMP),
            TRY_CAST(o.order_delivered_customer_date AS TIMESTAMP)
        )
    END AS delivery_days,
    CASE
        WHEN TRY_CAST(o.order_estimated_delivery_date AS TIMESTAMP) IS NOT NULL
        AND TRY_CAST(o.order_delivered_customer_date AS TIMESTAMP) IS NOT NULL
        THEN date_diff(
            'day',
            TRY_CAST(o.order_estimated_delivery_date AS TIMESTAMP),
            TRY_CAST(o.order_delivered_customer_date AS TIMESTAMP)
        )
    END AS delay_days,
    CASE 
        WHEN o.order_status <> 'delivered' THEN NULL
        WHEN TRY_CAST(o.order_delivered_customer_date AS TIMESTAMP) IS NULL
            OR TRY_CAST(o.order_estimated_delivery_date AS TIMESTAMP) IS NULL
        THEN NULL
        WHEN TRY_CAST(o.order_delivered_customer_date AS TIMESTAMP) 
        > TRY_CAST(o.order_estimated_delivery_date AS TIMESTAMP)
        THEN TRUE
        ELSE FALSE
    END AS is_late,
    r.review_score
FROM orders AS o
LEFT JOIN customers AS c ON o.customer_id = c.customer_id
LEFT JOIN order_totals AS t ON o.order_id = t.order_id
LEFT JOIN latest_reviews AS r ON o.order_id = r.order_id;