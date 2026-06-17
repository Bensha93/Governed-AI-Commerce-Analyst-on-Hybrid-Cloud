{{ config(materialized='view', schema='governed') }}

select
    order_id,
    order_status,
    order_purchase_date,
    item_count,
    total_item_price,
    total_freight_value,
    expected_order_value,
    total_payment_value,
    payment_difference,
    reconciliation_status,
    is_late_delivery
from {{ ref('mart_order_reconciliation') }}
