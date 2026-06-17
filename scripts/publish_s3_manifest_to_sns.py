"""Publish a simple S3 file-arrived event to SNS.

Usage:
    python scripts/publish_s3_manifest_to_sns.py \
      --topic-arn arn:aws:sns:eu-central-1:123456789012:topic \
      --bucket my-raw-bucket \
      --key olist/orders/olist_orders_dataset.csv \
      --dataset olist \
      --entity orders
"""

from __future__ import annotations

import argparse
import json
from datetime import datetime, timezone

import boto3


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--topic-arn", required=True)
    parser.add_argument("--bucket", required=True)
    parser.add_argument("--key", required=True)
    parser.add_argument("--dataset", required=True)
    parser.add_argument("--entity", required=True)
    args = parser.parse_args()

    message = {
        "event_type": "file_arrived",
        "event_timestamp": datetime.now(timezone.utc).isoformat(),
        "dataset": args.dataset,
        "entity": args.entity,
        "s3": {
            "bucket": args.bucket,
            "key": args.key,
        },
    }

    sns = boto3.client("sns")
    response = sns.publish(
        TopicArn=args.topic_arn,
        Message=json.dumps(message),
        Subject=f"{args.dataset}.{args.entity}.file_arrived",
    )
    print(json.dumps(response, indent=2, default=str))


if __name__ == "__main__":
    main()
