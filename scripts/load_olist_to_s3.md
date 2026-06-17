# Load Olist data to S3

Download the Olist dataset from Kaggle manually or using the Kaggle CLI, then upload CSV files to your raw S3 bucket.

Recommended S3 layout:

```text
s3://YOUR_RAW_BUCKET/olist/orders/olist_orders_dataset.csv
s3://YOUR_RAW_BUCKET/olist/order_items/olist_order_items_dataset.csv
s3://YOUR_RAW_BUCKET/olist/payments/olist_order_payments_dataset.csv
s3://YOUR_RAW_BUCKET/olist/customers/olist_customers_dataset.csv
s3://YOUR_RAW_BUCKET/olist/products/olist_products_dataset.csv
s3://YOUR_RAW_BUCKET/olist/sellers/olist_sellers_dataset.csv
s3://YOUR_RAW_BUCKET/olist/reviews/olist_order_reviews_dataset.csv
```

Example upload:

```bash
aws s3 cp ./data/olist_orders_dataset.csv s3://YOUR_RAW_BUCKET/olist/orders/olist_orders_dataset.csv
```

Then publish a file-arrived message:

```bash
python scripts/publish_s3_manifest_to_sns.py \
  --topic-arn YOUR_SNS_TOPIC_ARN \
  --bucket YOUR_RAW_BUCKET \
  --key olist/orders/olist_orders_dataset.csv \
  --dataset olist \
  --entity orders
```
