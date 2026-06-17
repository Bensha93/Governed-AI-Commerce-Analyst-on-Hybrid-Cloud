"""Simple SQL guard for the AI analyst agent.

This is intentionally conservative. In production, use a real SQL parser, IAM-based
controls, BigQuery authorized views, and query job restrictions.
"""

from __future__ import annotations

import re
from dataclasses import dataclass

BLOCKED_KEYWORDS = {
    "insert", "update", "delete", "merge", "drop", "alter", "create", "truncate",
    "grant", "revoke", "export", "load", "call"
}

BLOCKED_DATASETS = {
    "commerce_raw",
    "commerce_enriched",
    "commerce_dbt_marts",
}

ALLOWED_DATASET = "commerce_governed"


@dataclass
class PolicyDecision:
    allowed: bool
    reason: str


def validate_sql(sql: str) -> PolicyDecision:
    normalized = sql.strip().lower()

    if not normalized.startswith("select"):
        return PolicyDecision(False, "Only SELECT queries are allowed.")

    tokens = set(re.findall(r"[a-zA-Z_][a-zA-Z0-9_]*", normalized))
    forbidden = tokens.intersection(BLOCKED_KEYWORDS)
    if forbidden:
        return PolicyDecision(False, f"Blocked SQL keyword(s): {sorted(forbidden)}")

    for dataset in BLOCKED_DATASETS:
        if f"{dataset}." in normalized or f"`{dataset}." in normalized:
            return PolicyDecision(False, f"Dataset {dataset} is not accessible to the AI agent.")

    if ALLOWED_DATASET not in normalized:
        return PolicyDecision(False, f"Query must reference only the {ALLOWED_DATASET} dataset.")

    return PolicyDecision(True, "Query approved.")
