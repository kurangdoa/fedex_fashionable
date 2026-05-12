# fedex_fashionable

# Prerequisite

Install UV https://docs.astral.sh/uv/getting-started/installation/

## Virtual Environment

```
uv sync
source .venv/bin/activate
```

## Run in Docker

```
docker compose up --build -d
```

The pipeline will automatically run and you will be able to open the metabase with

http://localhost:3000/dashboard/4-fashionable?date=&ship_city=MUMBAI

## Run DBT locally

To run DBT locally you would need to do

```
dbt run --target prd-local
```

or below for dev environment
```
dbt run --target dev
```

## Create Presentation

To create presentation, you could follow guide here https://sli.dev/guide/
```
npm i -g pnpm
npx playwright install chromium
npm i -D playwright-chromium
npx slidev export
pnpm run dev
```
