{{ config(
    materialized='view',
    schema='bronze')
}}

SELECT
    /* --- Added Surrogate Keys --- */
    {{ dbt_utils.generate_surrogate_key(['"Order ID"', 'SKU']) }} AS order_product_key,
    {{ dbt_utils.generate_surrogate_key(['SKU']) }} AS product_key,
    {{ dbt_utils.generate_surrogate_key(['"ship-city"', '"ship-state"', '"ship-postal-code"']) }} AS location_key,

    "Order ID" AS order_id,
    strptime(date, '%m-%d-%y')::DATE AS date_key,
    status,
    fulfilment,
    "Sales Channel" AS sales_channel,
    "ship-service-level" AS ship_service_level,
    style,
    sku,
    category,
    size,
    asin,
    "Courier Status" AS courier_status,
    qty::INT AS qty,
    currency,
    amount::FLOAT AS amount,
    "ship-city" AS ship_city,
    "ship-state" AS ship_state,
    "ship-postal-code"::INT AS ship_postal_code,
    "ship-country" AS ship_country,
    "promotion-ids" AS promotion_ids,
    b2b,
    "fulfilled-by" AS fulfilled_by

FROM {{ source('fashionable__bronze', 'fashionable_sales') }}
