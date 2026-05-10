{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set my_prefix = 'rhyando' -%}

    {%- if (target.name == 'prd' or target.name == 'prd-local') and custom_schema_name is not none -%}
        {{ custom_schema_name | trim }}

    {%- elif target.name == 'dev' and custom_schema_name is not none -%}
        {{ my_prefix }}_{{ custom_schema_name | trim }}

    {# 4. Fallback for models without a custom schema #}
    {%- else -%}
        {{ target.schema }}

    {%- endif -%}
{%- endmacro %}
