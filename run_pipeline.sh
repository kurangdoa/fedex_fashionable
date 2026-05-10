#!/bin/bash
set -e

echo "Starting Ingestion"
uv run python ingestion/ingestion.py

echo "Running dbt Transformations"
uv run dbt deps --profiles-dir dbt --project-dir dbt
uv run dbt run --project-dir dbt --target prd --profiles-dir dbt

echo "Pipeline Complete!"
