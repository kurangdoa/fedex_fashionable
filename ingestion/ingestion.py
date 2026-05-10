import duckdb
import pandas as pd
import os
import zipfile
from data_profiling import ProfileReport

# -----
# unzip
# -----

os.makedirs("tmp", exist_ok=True)
zip_path = "ingestion/Fashionable Sale Report.csv.zip"
target_file = "Fashionable Sale Report.csv"
target_path = f"tmp/{target_file}"

with zipfile.ZipFile(zip_path, "r") as z:
    # Open the specific CSV file inside the zip, ignoring macOS metadata
    with z.open(target_file) as f:
        df = pd.read_csv(f, low_memory=False)
    df.to_csv(target_path, index=False)
    print("Successfully extracted to tmp/fashionable_report.csv")

# ----
# read
# ----

df = pd.read_csv(
    target_path,
)
print(df.head(2))

# create EDA report

report = ProfileReport(df, title="Fashionable Report", explorative=True)
report.to_file("ingestion/data_audit.html")

df.to_csv("tmp/Fashionable Sale Report.csv", index=False)

# --------------
# load to duckdb
# --------------

create_table_query = """
                    CREATE OR REPLACE TABLE bronze.fashionable_sales AS
                    SELECT * FROM read_csv_auto('tmp/Fashionable Sale Report.csv',
                            types={'date': 'VARCHAR'}
                    );
                    """

with duckdb.connect("./database/fashionable.db") as con:
    con.execute("CREATE SCHEMA IF NOT EXISTS bronze;")
    con.execute("CREATE SCHEMA IF NOT EXISTS silver;")
    con.execute("CREATE SCHEMA IF NOT EXISTS gold;")
    con.sql(create_table_query)
