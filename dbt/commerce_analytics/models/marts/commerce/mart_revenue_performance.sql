select
    date_trunc(order_purchase_date, month) as order_month,
    order_status,
    reconciliation_status,
    count(distinct order_id) as orders,
    sum(expected_order_value) as expected_revenue,
    sum(total_payment_value) as payment_revenue,
    sum(payment_difference) as total_payment_difference,
    countif(reconciliation_status != 'matched') as mismatched_orders
from {{ ref('mart_order_reconciliation') }}
group by 1, 2, 3
