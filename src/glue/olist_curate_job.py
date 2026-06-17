"""AWS Glue ETL starter script for Olist CSV files.

This script reads CSV files from the raw S3 zone and writes curated Parquet files.

Glue job parameters expected:
    --SOURCE_S3_PATH s3://bucket/olist/orders/
    --TARGET_S3_PATH s3://bucket/curated/olist/orders/
    --ENTITY orders
"""

from __future__ import annotations

import sys
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql import functions as F

args = getResolvedOptions(
    sys.argv,
    ["JOB_NAME", "SOURCE_S3_PATH", "TARGET_S3_PATH", "ENTITY"],
)

sc = SparkContext()
glue_context = GlueContext(sc)
spark = glue_context.spark_session
job = Job(glue_context)
job.init(args["JOB_NAME"], args)

source_path = args["SOURCE_S3_PATH"]
target_path = args["TARGET_S3_PATH"]
entity = args["ENTITY"]

raw_df = (
    spark.read.option("header", "true")
    .option("inferSchema", "true")
    .csv(source_path)
)

curated_df = (
    raw_df
    .withColumn("_source_entity", F.lit(entity))
    .withColumn("_ingested_at", F.current_timestamp())
)

# Keep transformations light here. Business transformations belong in dbt.
(
    curated_df.write.mode("overwrite")
    .format("parquet")
    .save(target_path)
)

job.commit()
