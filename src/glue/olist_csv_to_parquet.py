import re
from urllib.parse import urlparse

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions

from pyspark.context import SparkContext
from pyspark.sql.functions import current_timestamp, input_file_name
import sys


args = getResolvedOptions(
    sys.argv,
    [
        "JOB_NAME",
        "RAW_BUCKET",
        "CURATED_BUCKET",
    ],
)

RAW_BUCKET = args["RAW_BUCKET"]
CURATED_BUCKET = args["CURATED_BUCKET"]

INPUT_BASE_PATH = f"s3://{RAW_BUCKET}/incoming/olist/"
OUTPUT_BASE_PATH = f"s3://{CURATED_BUCKET}/curated/olist/"


def clean_column_name(column_name: str) -> str:
    """
    Convert column names to BigQuery/dbt-friendly snake_case.
    """
    cleaned = column_name.strip().lower()
    cleaned = re.sub(r"[^a-z0-9]+", "_", cleaned)
    cleaned = re.sub(r"_+", "_", cleaned)
    cleaned = cleaned.strip("_")
    return cleaned


def table_name_from_path(file_path: str) -> str:
    """
    Example:
    s3://bucket/incoming/olist/olist_orders_dataset.csv
    becomes:
    orders
    """
    path = urlparse(file_path).path
    file_name = path.split("/")[-1]

    table_name = file_name.replace(".csv", "")
    table_name = table_name.replace("olist_", "")
    table_name = table_name.replace("_dataset", "")
    table_name = table_name.replace("_category_name_translation", "category_translation")

    return table_name


sc = SparkContext()
glue_context = GlueContext(sc)
spark = glue_context.spark_session

job = Job(glue_context)
job.init(args["JOB_NAME"], args)

print(f"Reading Olist CSV files from: {INPUT_BASE_PATH}")

df = (
    spark.read.option("header", "true")
    .option("inferSchema", "false")
    .option("multiLine", "true")
    .option("escape", '"')
    .csv(INPUT_BASE_PATH)
    .withColumn("source_file", input_file_name())
    .withColumn("_ingested_at", current_timestamp())
)

# Clean column names
for old_col in df.columns:
    df = df.withColumnRenamed(old_col, clean_column_name(old_col))

# Get source file list
source_files = [row["source_file"] for row in df.select("source_file").distinct().collect()]

print(f"Found {len(source_files)} source files")

for source_file in source_files:
    table_name = table_name_from_path(source_file)
    output_path = f"{OUTPUT_BASE_PATH}{table_name}/"

    print(f"Processing table: {table_name}")
    print(f"Source file: {source_file}")
    print(f"Output path: {output_path}")

    table_df = df.filter(df["source_file"] == source_file)

    (
        table_df.coalesce(1)
        .write.mode("overwrite")
        .format("parquet")
        .save(output_path)
    )

job.commit()

print("Olist CSV to Parquet Glue job completed successfully.")