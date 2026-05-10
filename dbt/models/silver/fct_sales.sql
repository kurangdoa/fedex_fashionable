{{ config(
    materialized='table',
    schema='silver')
}}

with stg as (
    select
        {{ dbt_utils.generate_surrogate_key(['order_id', 'sku']) }} as order_product_key,
        order_id,
        date_key,
        {{ dbt_utils.generate_surrogate_key(['sku']) }} as product_key,
        sku,
        status,
        fulfilment,
        sales_channel,
        {{ dbt_utils.generate_surrogate_key(['ship_city', 'ship_state', 'ship_postal_code']) }} as location_key,
        ship_service_level,
        coalesce(courier_status, 'Unknown') as courier_status,
        fulfilled_by,
        b2b,
        promotion_ids,
        qty,
        coalesce(currency, 'Unknown') as currency,
        coalesce(amount, 0) as amount
    from {{ ref('stg_sales') }}
    where
        date_key > cast('2022-03-31' as date)
)

select * from stg
qualify row_number() over (partition by order_product_key order by date_key desc) = 1
