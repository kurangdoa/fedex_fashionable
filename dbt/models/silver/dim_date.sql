-- depends_on: {{ ref('fct_sales') }}

{{ config(
    materialized='table',
    schema='silver')
}}

{% set start_date = "2015-01-01" %}
{% set end_date = "2022-12-31" %}

-- This block only runs during the 'execution' phase
{% if execute %}
    {% set get_date_range %}
        select
            min(date_key) as min_date,
            max(date_key) as max_date
        from {{ ref('fct_sales') }}
    {% endset %}

    {% set results = run_query(get_date_range) %}

    -- Check if we actually got results back
    {% if results %}
        {% set start_date = results.columns[0].values()[0] | string %}
        {% set end_date = results.columns[1].values()[0] | string %}
    {% endif %}
{% endif %}

{{ dbt_date.get_date_dimension(start_date, end_date) }}
