"""Audit logger for AI analyst agent interactions."""

from __future__ import annotations

import os
import uuid
from datetime import datetime, timezone
from typing import Sequence

from google.cloud import bigquery


def write_audit_log(
    *,
    user_id: str,
    user_role: str,
    business_purpose: str,
    question: str,
    generated_sql: str,
    approved_sql: str | None,
    tables_used: Sequence[str],
    policy_decision: str,
    row_count_returned: int | None,
    answer_summary: str | None,
    model_used: str | None,
    execution_status: str,
) -> None:
    client = bigquery.Client()
    table_id = os.environ.get("AI_AGENT_AUDIT_TABLE")
    if not table_id:
        raise RuntimeError("AI_AGENT_AUDIT_TABLE environment variable is required.")

    row = {
        "audit_id": str(uuid.uuid4()),
        "event_timestamp": datetime.now(timezone.utc).isoformat(),
        "user_id": user_id,
        "user_role": user_role,
        "business_purpose": business_purpose,
        "question": question,
        "generated_sql": generated_sql,
        "approved_sql": approved_sql,
        "tables_used": list(tables_used),
        "policy_decision": policy_decision,
        "row_count_returned": row_count_returned,
        "answer_summary": answer_summary,
        "model_used": model_used,
        "execution_status": execution_status,
    }

    errors = client.insert_rows_json(table_id, [row])
    if errors:
        raise RuntimeError(f"Failed to insert audit log: {errors}")
