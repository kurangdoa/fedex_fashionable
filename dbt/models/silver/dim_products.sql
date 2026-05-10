{{ config(materialized='table', schema='silver') }}

SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['sku']) }} AS product_key,
    sku,
    style,
    category,
    size,
    asin
FROM {{ ref('stg_sales') }}
