"""BigQuery query helper for the AI analyst agent."""

from __future__ import annotations

from google.cloud import bigquery


def run_query(sql: str, maximum_bytes_billed: int = 1_000_000_000) -> list[dict]:
    client = bigquery.Client()
    job_config = bigquery.QueryJobConfig(
        maximum_bytes_billed=maximum_bytes_billed,
        use_query_cache=True,
    )
    query_job = client.query(sql, job_config=job_config)
    rows = query_job.result()
    return [dict(row) for row in rows]
