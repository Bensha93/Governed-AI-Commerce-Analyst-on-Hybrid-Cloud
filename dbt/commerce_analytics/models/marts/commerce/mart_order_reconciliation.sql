select
    order_id,
    customer_id,
    order_status,
    order_purchase_date,
    item_count,
    total_item_price,
    total_freight_value,
    expected_order_value,
    total_payment_value,
    round(total_payment_value - expected_order_value, 2) as payment_difference,
    case
        when order_status = 'canceled' then 'excluded_cancelled_order'
        when expected_order_value = 0 and total_payment_value > 0 then 'payment_without_items'
        when expected_order_value > 0 and total_payment_value = 0 then 'missing_payment'
        when abs(total_payment_value - expected_order_value) <= 0.01 then 'matched'
        when total_payment_value > expected_order_value then 'overpaid'
        when total_payment_value < expected_order_value then 'underpaid'
        else 'unknown'
    end as reconciliation_status,
    is_late_delivery
from {{ ref('fact_orders') }}
