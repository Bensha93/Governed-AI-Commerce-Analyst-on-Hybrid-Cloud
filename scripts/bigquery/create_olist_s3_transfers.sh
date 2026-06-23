#!/usr/bin/env bash
set -euo pipefail

PROJECT_ID="${PROJECT_ID:-governed-ai-commerce-analyst}"
DATASET="${DATASET:-commerce_raw}"
BQ_LOCATION="${BQ_LOCATION:-EU}"

: "${CURATED_BUCKET:?CURATED_BUCKET is required}"
: "${AWS_TRANSFER_ACCESS_KEY_ID:?AWS_TRANSFER_ACCESS_KEY_ID is required}"
: "${AWS_TRANSFER_SECRET_ACCESS_KEY:?AWS_TRANSFER_SECRET_ACCESS_KEY is required}"

create_transfer() {
  local table="$1"
  local path="$2"

  echo "Creating BigQuery S3 transfer for olist_${table}..."

  bq mk \
    --transfer_config \
    --project_id="${PROJECT_ID}" \
    --location="${BQ_LOCATION}" \
    --data_source=amazon_s3 \
    --target_dataset="${DATASET}" \
    --display_name="olist_${table}_s3_to_bigquery" \
    --params="{
      \"destination_table_name_template\":\"olist_${table}\",
      \"data_path\":\"s3://${CURATED_BUCKET}/${path}\",
      \"access_key_id\":\"${AWS_TRANSFER_ACCESS_KEY_ID}\",
      \"secret_access_key\":\"${AWS_TRANSFER_SECRET_ACCESS_KEY}\",
      \"file_format\":\"PARQUET\",
      \"write_disposition\":\"WRITE_TRUNCATE\"
    }"
}

create_transfer "orders" "curated/olist/orders/*.parquet"
create_transfer "order_items" "curated/olist/order_items/*.parquet"
create_transfer "order_payments" "curated/olist/order_payments/*.parquet"
create_transfer "customers" "curated/olist/customers/*.parquet"
create_transfer "products" "curated/olist/products/*.parquet"
create_transfer "sellers" "curated/olist/sellers/*.parquet"

echo "Done creating Olist S3 to BigQuery transfer configs."
