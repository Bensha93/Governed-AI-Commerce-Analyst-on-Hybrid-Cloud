{{ config(materialized='view', schema='governed') }}

select
    order_month,
    order_status,
    reconciliation_status,
    orders,
    expected_revenue,
    payment_revenue,
    total_payment_difference,
    mismatched_orders
from {{ ref('mart_revenue_performance') }}
