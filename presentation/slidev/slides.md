---
theme: seriph
background: https://cover.sli.dev
title: Fashionable Data Pipeline
info: |
  ## Analytics Engineer Assessment
  Prepared using Slidev, DuckDB, dbt, and Metabase.
class: text-center
drawings:
  persist: false
transition: slide-left
comark: true
duration: 40min
---

# Fashionable Data Pipeline
Analytics Engineering Assessment

**Prepared by:** Rhyando
**Stack:** DuckDB, dbt, Metabase, Python

<div @click="$slidev.nav.next" class="mt-12 py-1 cursor-pointer" hover:bg="white op-10">
  Press Space to begin <carbon:arrow-right />
</div>

<div class="abs-br m-6 text-xl">
  <button @click="$slidev.nav.openInEditor()" title="Open in Editor" class="slidev-icon-btn">
    <carbon:edit />
  </button>
  <a href="https://github.com/yourusername/fedex_fashionable" target="_blank" class="slidev-icon-btn">
    <carbon:logo-github />
  </a>
</div>

---
layout: two-cols
layoutClass: gap-16
transition: fade-out
---

# Agenda

<Toc minDepth="2" maxDepth="2" class="mt-8 text-xl" />

::right::

<div class="mt-20">
  <p class="text-gray-500 italic">"Design a data warehouse using the Kimball star schema model, aimed at facilitating marketers' analytical tasks."</p>

</div>

---
transition: slide-up
level: 2
---

## Requirements & Principles

To ensure the solution meets the business needs, the following core requirements guided the pipeline design:

<div class="grid grid-cols-2 gap-8 mt-8">

<div v-click>

### ⚙️ Functional Requirements
- **Transformation:** Must use **dbt** and **SQL**.
- **Modeling:** Design a **Kimball Star Schema** data warehouse.
- **Integration:** Must be seamlessly connected to a **BI Tool** (Metabase).

</div>

<div v-click>

### 🌟 Non-Functional Requirements
- **User Friendliness:** The data warehouse and BI layer must be highly intuitive, aimed at facilitating marketers' analytical tasks without friction.
- **Data Quality:** Need to ensure data quality for better trust from the marketer.

</div>

</div>

---
transition: slide-up
level: 2
---

## How did you explore the data?

<style>
li {
  font-size: 12px;
  line-height: 1.5;
  margin-bottom: 0.5em;
  margin-left: 2em;
}
</style>

Before building models, I needed to understand the shape, grain, and quality of the raw CSV.

<div class="grid grid-cols-2 gap-8 mt-8">

<div v-click>

### 🛠 Tools Used
- **Python (Pandas):** Initial load and inspection.
- **YData Profiling:** Automated statistical audit.
- **DuckDB:** Quick SQL ad-hoc queries.
- **Excel:** for quick raw data exploration

The profiling can be found here: <a href="file:///Users/rhyando/code/fedex_fashionable/ingestion/data_audit.html" target="_blank">ingestion/data_audit.html</a>

</div>

<div v-click>

### 🔍 Key Findings
- **Grain:** One row per order line item.
- **Volume:** ~128,975 rows.
- **Data Issues:**
  - There is no unique row id and the column `index` is not a standard row id
  - `date` column in MM-DD-YY format is not standard and consistent.
  - Column `Unnamed: 22` has no actual meaning.
- **Missing Values:**
  - Missing `ship-city` fields.
  - 6.0% missing values in `Amount`.
</div>

</div>
<div v-click class="mt-12 p-4 bg-gray-100 rounded text-gray-800">
  <carbon:idea /> <strong>Takeaway:</strong> There are a lot of data quality implementation that hasn't been found. Only after more exploration, it can only be found and implemented.
</div>

---
level: 2
---

## High-Level Architecture & Ingestion Flow

The data pipeline is designed to be simple, reproducible, and fully local.

<br>

```mermaid {theme: 'neutral', scale: 0.75}
graph LR
Source["📄 Source<br/>(.zip)"] --> Python["🐍 Ingestion<br/>(Python to unzip)"]
Python --> DuckDB["🦆 Storage<br/>(DuckDB)"]
DuckDB --> dbt["⚙️ Transformation<br/>(dbt)"]
dbt --> Metabase["📊 Visualization<br/>(Metabase)"]
```

<div class="mt-8" v-click>

### Workflow Breakdown:
1. **Source:** The assessment provided raw data in a compressed format.
2. **Ingestion:** A Python script automatically extracts the `.zip` file and loads the raw `.csv` into DuckDB.
3. **Transformation:** dbt takes over to clean, deduplicate, and model the data into a Kimball Star Schema.
4. **Visualization:** Metabase connects directly to the local DuckDB database to serve dashboards to the marketeers.

</div>

---
level: 2
---

## How did you clean the data?

<style>
li {
  font-size: 12px;
  line-height: 1.5;
  margin-bottom: 0.5em;
  margin-left: 2em;
}
</style>

Data cleaning was handled systematically across two layers:
- **Python Ingestion**: mainly used as automatic pandas column schema and put data to duckdb.
- **dbt Staging (Silver)**: Cleaning up mainly done in the silver layer.

<v-click>

<br>

List of changes:

- **Standardization:** Converted column names to `snake_case` during ingestion.
- **Data Types:**
  - Explicitly cast dates to `DATE` types in dbt from MM-DD-YY to normal YYYY-MM-DD.
  - Change format such as `Amount` to `FLOAT` and `ship-postal-code` to `INT`.
- **Handling Nulls:** Monitored missing columns such as `Amount` values (6%). Imputed or filtered where necessary.
- **Deduplication:** Applied window functions in DuckDB to eliminate duplicated order lines.
- **Remove:** Removing the first date of the data due to unusually low value.

</v-click>

---
layout: default
---

## Facts and Dimensions Reasoning

<style>
li {
  font-size: 13px;
  line-height: 1.5;
  margin-bottom: 0.5em;
  margin-left: 2em;
}
</style>

To support the marketing team, I designed a **Kimball Star Schema** to make querying intuitive and performant.

<div class="grid grid-cols-2 gap-4 mt-8">

<div>
  <div v-click>

  ### 🟢 Fact Table
  **`fct_sales`**
  - **Grain:** One row per order line item.
  - **Measures:** Quantity, Amount.
  - **Keys:** `order_id`, `product_key`, `location_key`, `date_key`.

  </div>

  <div v-click class="mt-6">

  ### 🔵 Dimension Tables
  - **`dim_products`**: Product attributes (`sku`, `category`, `style`, `size`, etc).
  - **`dim_locations`**: Shipping destinations (`ship_city`, `ship_state`, etc).
  - **`dim_date`**: Calendar attributes (`month`, `quarter`, `season`, etc).

  </div>
</div>

<div v-click>

```mermaid {scale: 0.7, theme: 'neutral'}
erDiagram
    dim_products ||--o{ fct_sales : "product_key"
    dim_locations ||--o{ fct_sales : "location_key"
    dim_date ||--o{ fct_sales : "date_key"

    fct_sales {
        int qty
        float amount
    }
```

</div>

</div>

---
layout: default
---

## How did you set up dbt?

The dbt project is organized following dbt Labs' best practices.

<div class="grid grid-cols-2 gap-8 mt-4">

<div>
  <ul class="mt-4 space-y-2">
    <li v-click><b>Adapter:</b> <code>dbt-duckdb</code> for fast, local, analytical querying.</li>
    <li v-click><b>Sources (Bronze Layer):</b> Defined <code>source.yml</code> pointing to raw data already in DuckDB. It also include <code>stg_</code> which is minor adjustment.</li>
    <li v-click><b>Silver Layer:</b> <code>dim_</code>, and <code>fct_</code> models to clean, deduplicate, and build the core star schema.</li>
    <li v-click><b>Golden Layer (Marts):</b> <code>mart_</code> models containing business-level aggregations directly for BI.</li>
  </ul>
</div>

<div v-click class="bg-gray-800 text-white p-4 rounded-lg shadow-lg text-sm font-mono mt-4">
dbt/models/<br>
├── bronze/<br>
│   ├── _silver_models.yml<br>
│   ├── stg_sales.sql<br>
├── silver/<br>
│   ├── dim_locations.sql<br>
│   ├── dim_date.sql<br>
│   ├── dim_products.sql<br>
│   └── fct_sales.sql<br>
├── gold/<br>
│   └── mart_sales.sql<br>
│   └── obt_sales.sql<br>
</div>

</div>

---
layout: default
---

## Preparing Data for BI & Answering Marketeers

The dimensional model directly answers the core business questions.

<div class="grid grid-cols-2 gap-6 mt-6">

<div v-click class="p-4 bg-blue-50 border border-blue-200 rounded-lg">
  <h3 class="text-blue-800 !mb-2 !text-lg">Q: Popular in Mumbai?</h3>
  <p class="text-sm text-gray-700">Filter <code>dim_locations.ship_city = 'MUMBAI'</code>.<br>Group by <code>dim_products.style</code> and <code>category</code>, summing <code>fct_sales.qty</code>.</p>
</div>

<div v-click class="p-4 bg-green-50 border border-green-200 rounded-lg">
  <h3 class="text-green-800 !mb-2 !text-lg">Q: Seasonal Sales Trend?</h3>
  <p class="text-sm text-gray-700">Join <code>dim_date</code> and group by <code>season</code>.<br>Sum <code>fct_sales.amount</code> to visualize gross revenue trends.</p>
</div>

</div>

<div v-click class="mt-8">

**BI Integration (Metabase):**
- Connected Metabase directly to the DuckDB file.
- Created fact and dimension in silver layer for marketer who want to tap into the raw table.
- Created `mart_sales` in gold layer containing aggregated data from raw tables.
- Created a denormalized "One Big Table" (`obt_sales`) view to make self-serve BI exploration easier for marketeers without requiring complex joins.

</div>


---
layout: default
---

## Metabase Example

<div v-click class="mt-6 flex justify-center">
  <img src="./images/metabase.png" alt="Metabase Dashboard" class="h-96 rounded shadow-lg border border-gray-200" />
</div>

---
layout: default
---

## How do you guarantee data quality?

Implemented robust testing in dbt to ensure data reliability.

<div class="mt-6">

<v-clicks>

- **Primary Key Tests:** <code>unique</code> and <code>not_null</code> on <code>order_id</code> + <code>sku</code> in staging, and surrogate keys in marts.
- **Referential Integrity:** <code>relationships</code> tests to ensure <code>fct_sales</code> keys exist in dimension tables.
- **Accepted Values:** Ensured order status and categories fall within expected static lists.
- **Custom Warnings:** Set severity to <code>warn</code> for the missing 6% <code>Amount</code> data, acknowledging the historical gap without failing the pipeline.

</v-clicks>

</div>

This data quality is implemented inside dbt test but not enforced right now.

---
layout: default
---

## Future Improvements

<style>
li {
  font-size: 12px;
  line-height: 1.5;
  margin-bottom: 0.5em;
  margin-left: 2em;
}
</style>

Given more than 4-6 hours, here is how I would evolve this architecture for scale:

<br>

<v-clicks>

1. 🚀 **Incremental Models:** Transition `fct_sales` from a full `table` rebuild to an `incremental` materialization to optimize processing time and compute costs as data volume grows.
2. 🤖 **CI/CD Automation:** Implement GitHub Actions to enforce data quality by running `dbt test` and `dbt build` automatically on every Pull Request.
3. 📖 **Data Cataloging & Lineage:** Generate and host `dbt docs` to provide marketers and analysts with a self-serve, searchable data dictionary and visual lineage graph.
4. ☁️ **Cloud DWH Migration:** Transition from a local DuckDB instance to a cloud-native platform like Snowflake or BigQuery to support multi-user concurrency and larger datasets.
5. 🧹 **Advanced Data Cleansing:** Implement more rigorous data quality checks and anomaly detection, such as fuzzy matching for missing or misspelled city names.
6. 📝 **Comprehensive Documentation:** Expand model-level and column-level descriptions in `schema.yml` to ensure business logic is fully transparent and maintainable.
7. **Additional Data Source:** Marketer's ask about seasonal could not be solved because there is no external data source.
8. **Proper BI Tool:** Move away from metabase to the more user friendly (paid) one such as PowerBI or Tableau

</v-clicks>

---
layout: center
class: text-center
---

## Thank You!

**Questions?**

AI (Gemini) is being used mainly for brainstorming, doing repetitive stuff, and this documentation.

<PoweredBySlidev mt-10 />
