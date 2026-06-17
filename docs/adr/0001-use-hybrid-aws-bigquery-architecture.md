# ADR 0001: Use Hybrid AWS + BigQuery Architecture

## Status

Accepted

## Context

The project is designed to demonstrate a hybrid data engineering architecture. AWS is used for ingestion, event routing, ETL, orchestration, and AI-agent execution. BigQuery is used as the analytical warehouse.

## Decision

Use AWS for the upstream operational and AI orchestration layer, and use BigQuery for analytical storage and governed querying.

## Consequences

### Advantages

- Demonstrates cross-cloud data engineering.
- Shows ability to integrate AWS event-driven systems with BigQuery analytics.
- Provides a realistic enterprise pattern where data sources and warehouse may live in different clouds.
- Allows use of Amazon Bedrock Agent while still using BigQuery as the warehouse.

### Disadvantages

- More IAM and networking complexity.
- Cross-cloud transfer and egress cost considerations.
- More operational complexity than a single-cloud architecture.
- Requires careful credential management between AWS and GCP.
