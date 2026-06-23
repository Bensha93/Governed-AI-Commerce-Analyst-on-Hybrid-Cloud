import re
import sys
from urllib.parse import urlparse

import boto3
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql.functions import current_timestamp, lit


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

INPUT_PREFIX = "incoming/olist/"
OUTPUT_BASE_PATH = f"s3://{CURATED_BUCKET}/curated/olist/"


def clean_column_name(column_name: str) -> str:
    cleaned = column_name.strip().lower()
    cleaned = re.sub(r"[^a-z0-9]+", "_", cleaned)
    cleaned = re.sub(r"_+", "_", cleaned)
    return cleaned.strip("_")


def table_name_from_key(key: str) -> str:
    file_name = key.split("/")[-1]

    table_name = file_name.replace(".csv", "")
    table_name = table_name.replace("olist_", "")
    table_name = table_name.replace("_dataset", "")

    if table_name == "product_category_name_translation":
        return "product_category_translation"

    return table_name


def list_csv_files(bucket: str, prefix: str) -> list[str]:
    s3 = boto3.client("s3")
    keys = []

    paginator = s3.get_paginator("list_objects_v2")
    for page in paginator.paginate(Bucket=bucket, Prefix=prefix):
        for obj in page.get("Contents", []):
            key = obj["Key"]
            if key.endswith(".csv"):
                keys.append(key)

    return keys


sc = SparkContext()
glue_context = GlueContext(sc)
spark = glue_context.spark_session

job = Job(glue_context)
job.init(args["JOB_NAME"], args)

csv_keys = list_csv_files(RAW_BUCKET, INPUT_PREFIX)

if not csv_keys:
    raise RuntimeError(f"No CSV files found in s3://{RAW_BUCKET}/{INPUT_PREFIX}")

print(f"Found {len(csv_keys)} CSV files")

for key in csv_keys:
    table_name = table_name_from_key(key)
    input_path = f"s3://{RAW_BUCKET}/{key}"
    output_path = f"{OUTPUT_BASE_PATH}{table_name}/"

    print(f"Processing {input_path}")
    print(f"Writing to {output_path}")

    df = (
        spark.read.option("header", "true")
        .option("inferSchema", "false")
        .option("multiLine", "true")
        .option("escape", '"')
        .csv(input_path)
    )

    for old_col in df.columns:
        df = df.withColumnRenamed(old_col, clean_column_name(old_col))

    df = (
        df.withColumn("_source_file", lit(input_path))
        .withColumn("_ingested_at", current_timestamp())
    )

    (
        df.coalesce(1)
        .write.mode("overwrite")
        .format("parquet")
        .save(output_path)
    )

job.commit()
print("Olist CSV to Parquet job completed successfully.")