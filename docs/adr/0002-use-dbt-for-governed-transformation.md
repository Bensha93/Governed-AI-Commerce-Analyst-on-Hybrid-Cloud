# ADR 0002: Use dbt for Governed Transformation Instead of Dataform

## Status

Accepted

## Context

The project needs more than SQL transformation. It needs governed analytics engineering before exposing data to an AI analyst agent.

## Decision

Use dbt for the transformation layer.

## Rationale

Dataform is a valid GCP-native choice for BigQuery SQL workflows. dbt is selected here because the project needs:

- Modular staging, intermediate, fact, dimension, and mart models.
- Reusable tests and reconciliation checks.
- Documentation generation.
- CI/CD-friendly workflow.
- Strong analytics engineering conventions.
- Better portability if the warehouse changes in the future.
- Clear governance boundary before the AI agent.

## Important clarification

The decision is not because Dataform cannot work with large data. Both dbt and Dataform ultimately run SQL on BigQuery. The scalability depends heavily on BigQuery design: partitioning, clustering, incremental models, materialization choices, and query optimization.

## Consequences

### Advantages

- Stronger portfolio value for analytics engineering roles.
- Clear business logic ownership.
- Easier to document and test model lineage.
- Better framework for reconciliation marts.

### Disadvantages

- More setup than a fully managed Dataform workflow.
- Requires dbt environment and deployment discipline.
- May require extra orchestration through CI/CD, MWAA, Step Functions, or Cloud Composer.
