FROM ghcr.io/astral-sh/uv:python3.12-bookworm-slim

WORKDIR /usr/app

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Enable bytecode compilation
ENV UV_PROJECT_ENVIRONMENT="/usr/local"
ENV UV_COMPILE_BYTECODE=1

# Copy dependency files first for better caching
COPY pyproject.toml uv.lock ./

# Install all dependencies (pandas, dbt-duckdb, duckdb, etc.)
RUN uv lock
RUN uv sync --frozen --no-install-project

# Copy the rest of the code (ingestion folder, dbt folder, and the .db file if it exists)
COPY . .

# Set the entrypoint to our pipeline script
RUN chmod +x ./run_pipeline.sh
ENTRYPOINT ["./run_pipeline.sh"]
