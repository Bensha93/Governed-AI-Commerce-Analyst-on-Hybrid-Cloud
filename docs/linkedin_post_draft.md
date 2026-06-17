# LinkedIn Post Draft

I recently started building a hybrid cloud data engineering project called **Hybrid Cloud Governed AI Commerce Analyst**.

The idea is simple: an AI data analyst should not query raw data directly.

In many analytics systems, raw data contains duplicates, incomplete records, inconsistent business logic, and sometimes sensitive fields. If an AI agent is allowed to query that layer directly, the answer may be fast, but not necessarily trusted.

So I designed the architecture this way:

```text
AWS S3 → SNS/SQS → AWS Glue → S3 Curated Parquet → BigQuery → dbt → Certified Views → Amazon Bedrock Agent → Audit Log
```

The project uses two open datasets:

- GA4 e-commerce sample data for customer journey analytics
- Olist e-commerce data for orders, payments, freight, delivery, and reconciliation

The key design decision is to place dbt before the AI agent. dbt defines the governed models, tests, reconciliation checks, and certified marts. The AI agent can only query approved BigQuery views, not raw tables.

This makes the agent more than a chatbot connected to a database. It becomes a governed analyst that works with trusted, documented, and auditable data.

That is where modern data engineering, analytics governance, and AI meet.
