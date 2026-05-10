{{ config(materialized='table', schema='silver') }}

SELECT DISTINCT
    {{ dbt_utils.generate_surrogate_key(['ship_city', 'ship_state', 'ship_postal_code']) }} AS location_key,
    upper(ship_city) AS ship_city,
    CASE
        WHEN contains(upper(ship_city), 'BENGALURU') THEN 'BENGALURU'
        WHEN contains(upper(ship_city), 'HYDERABAD') THEN 'HYDERABAD'
        WHEN contains(upper(ship_city), 'MUMBAI') THEN 'MUMBAI'
        WHEN contains(upper(ship_city), 'CHENNAI') THEN 'CHENNAI'
        WHEN contains(upper(ship_city), 'DELHI') THEN 'DELHI'
        WHEN contains(upper(ship_city), 'KOLKATA') THEN 'KOLKATA'
        WHEN contains(upper(ship_city), 'PUNE') THEN 'PUNE'
        WHEN contains(upper(ship_city), 'NOIDA') THEN 'NOIDA'
        WHEN contains(upper(ship_city), 'THANE') THEN 'THANE'
        ELSE 'OTHER_CITIES' END
        AS ship_city_group,
    upper(ship_state) AS ship_state,
    ship_postal_code,
    ship_country
FROM {{ ref('stg_sales') }}
