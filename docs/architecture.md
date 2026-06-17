# Architecture: Hybrid Cloud Governed AI Commerce Analyst

## Objective

Build a governed AI analyst platform where AWS handles ingestion and AI orchestration, while BigQuery handles analytical storage and dbt handles governed transformations.

## Main architectural principle

The AI analyst agent must not query raw tables. It can only query certified BigQuery views that are tested, reconciled, masked, and audited.

## Logical layers

| Layer | Platform | Responsibility |
|---|---|---|
| Landing | AWS S3 | Store raw source files |
| Event routing | AWS SNS/SQS | Notify downstream jobs reliably |
| ETL | AWS Glue | Clean files and convert to Parquet |
| Transfer | BigQuery DTS | Load curated S3 files into BigQuery |
| Warehouse | BigQuery | Raw, enriched, mart, governed, audit layers |
| Transformation | dbt | Staging, facts, dimensions, marts, tests, reconciliation |
| Governed access | BigQuery views | Certified and masked data access |
| AI analyst | Amazon Bedrock + Lambda | Controlled question-to-SQL and answer generation |
| Audit | BigQuery + S3 | Log question, SQL, data source, role, answer |

## BigQuery dataset layout

```text
commerce_raw        -- raw imported source tables
commerce_enriched   -- cleaned and standardized tables
commerce_dbt_marts  -- dbt facts, dimensions, marts
commerce_governed   -- authorized/certified views exposed to AI agent
commerce_audit      -- AI agent logs and policy decisions
```

## AI access rule

```text
Allowed: commerce_governed.*
Blocked: commerce_raw.*, commerce_enriched.*, unrestricted marts
```

## Data governance rules

1. Raw data is immutable and restricted.
2. Enriched data is validated but still restricted.
3. dbt models define business logic.
4. Reconciliation models define trusted financial/order integrity checks.
5. Governed views expose only the minimum data needed.
6. The AI agent must validate generated SQL before execution.
7. All AI interactions must be logged.
