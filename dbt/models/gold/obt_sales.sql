{{ config(
    materialized='table',
    schema='gold'
) }}

WITH fct_sales AS (
    SELECT * FROM {{ ref('fct_sales') }}
),

dim_products AS (
    SELECT * FROM {{ ref('dim_products') }}
),

dim_locations AS (
    SELECT * FROM {{ ref('dim_locations') }}
),

dim_date AS (
    SELECT * FROM {{ ref('dim_date') }}
)

SELECT
    -- Fact fields
    f.date_key,
    f.sku,
    f.status,
    f.fulfilment,
    coalesce(f.b2b IS NOT null, false) AS is_b2b,
    coalesce(f.promotion_ids IS NOT null, false)
        AS is_promotion,
    f.currency,

    -- Product fields
    p.style,
    p.category,

    -- Location fields
    l.ship_city_group,
    l.ship_country,

    -- Date fields
    d.day_of_week_name,
    d.month_name,
    d.quarter_of_year,
    d.year_number,

    -- Aggregated Metrics
    count(DISTINCT f.order_id) AS number_of_orders,
    sum(f.qty) AS sum_quantity,
    sum(f.amount) AS sum_amount

FROM fct_sales AS f
LEFT JOIN dim_products AS p ON f.product_key = p.product_key
LEFT JOIN dim_locations AS l ON f.location_key = l.location_key
LEFT JOIN dim_date AS d ON f.date_key = d.date_day
GROUP BY
    1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15
