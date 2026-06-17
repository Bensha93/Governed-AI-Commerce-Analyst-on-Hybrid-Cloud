"""AWS Lambda handler for an Amazon Bedrock Agent action group.

This starter expects the agent to pass a generated SQL query and metadata.
In production, add stricter parsing, role checks, prompt-injection defenses, and
parameterized query templates where possible.
"""

from __future__ import annotations

import json
import os
from typing import Any

from app.agent.audit_log import write_audit_log
from app.agent.query_bigquery import run_query
from app.agent.sql_guard import validate_sql


def lambda_handler(event: dict[str, Any], context: Any) -> dict[str, Any]:
    body = event.get("requestBody", {}).get("content", {}).get("application/json", {}).get("properties", [])
    payload = {item.get("name"): item.get("value") for item in body}

    user_id = payload.get("user_id", "unknown")
    user_role = payload.get("user_role", "AI_ANALYST_USER")
    business_purpose = payload.get("business_purpose", "commerce_analytics")
    question = payload.get("question", "")
    generated_sql = payload.get("generated_sql", "")
    model_used = payload.get("model_used", os.environ.get("BEDROCK_MODEL_ID", "unknown"))

    decision = validate_sql(generated_sql)

    if not decision.allowed:
        write_audit_log(
            user_id=user_id,
            user_role=user_role,
            business_purpose=business_purpose,
            question=question,
            generated_sql=generated_sql,
            approved_sql=None,
            tables_used=[],
            policy_decision=f"blocked: {decision.reason}",
            row_count_returned=None,
            answer_summary=None,
            model_used=model_used,
            execution_status="blocked",
        )
        return _bedrock_response({"allowed": False, "reason": decision.reason})

    rows = run_query(generated_sql)
    answer_summary = f"Query returned {len(rows)} rows."

    write_audit_log(
        user_id=user_id,
        user_role=user_role,
        business_purpose=business_purpose,
        question=question,
        generated_sql=generated_sql,
        approved_sql=generated_sql,
        tables_used=["commerce_governed"],
        policy_decision="approved",
        row_count_returned=len(rows),
        answer_summary=answer_summary,
        model_used=model_used,
        execution_status="success",
    )

    return _bedrock_response({"allowed": True, "rows": rows[:100], "row_count": len(rows)})


def _bedrock_response(payload: dict[str, Any]) -> dict[str, Any]:
    return {
        "messageVersion": "1.0",
        "response": {
            "actionGroup": "QueryBigQueryGovernedViews",
            "function": "query_bigquery",
            "functionResponse": {
                "responseBody": {
                    "TEXT": {
                        "body": json.dumps(payload, default=str)
                    }
                }
            },
        },
    }
