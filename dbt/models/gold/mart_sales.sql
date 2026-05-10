{{ config(
    materialized='table',
    schema='gold')
}}

WITH sales_staging AS (
    SELECT *
    FROM {{ ref('fct_sales') }}
),

joined_keys AS (
    SELECT
        s.order_id,
        s.date_key,
        s.status,
        s.b2b AS is_b2b,
        p.product_key,
        l.location_key,
        s.qty,
        s.currency,
        s.amount,
        coalesce(s.promotion_ids IS NOT null, false)
            AS is_promotion
    FROM sales_staging AS s
    LEFT JOIN {{ ref('dim_products') }} AS p ON s.product_key = p.product_key
    LEFT JOIN {{ ref('dim_locations') }} AS l ON s.location_key = l.location_key
)

SELECT
    product_key,
    location_key,
    date_key,

    -- Volume Metrics
    count(DISTINCT order_id) AS total_orders,
    sum(qty) AS total_qty,
    sum(amount) AS gross_revenue,

    -- Business Health (Cancellations)
    count(DISTINCT CASE WHEN status = 'Cancelled' THEN order_id END)
        AS cancelled_orders,
    sum(CASE WHEN status = 'Cancelled' THEN amount ELSE 0 END)
        AS cancelled_revenue,

    -- Net Metrics
    sum(CASE WHEN status <> 'Cancelled' THEN amount ELSE 0 END) AS net_revenue,

    -- Customer/Order Efficiency
    round(sum(amount) / nullif(count(DISTINCT order_id), 0), 2)
        AS avg_order_value,
    round(sum(qty) / nullif(count(DISTINCT order_id), 0), 2) AS items_per_order,

    -- Segment Metrics
    count(DISTINCT CASE WHEN is_b2b = true THEN order_id END) AS b2b_orders,
    sum(CASE WHEN is_b2b = true THEN amount ELSE 0 END) AS b2b_revenue,

    -- Promotion Metrics
    count(DISTINCT CASE WHEN is_promotion = true THEN order_id END)
        AS promotion_orders,
    sum(CASE WHEN is_promotion = true THEN amount ELSE 0 END)
        AS promotion_revenue

FROM joined_keys
GROUP BY 1, 2, 3
