with orders as (
    select * from {{ ref('stg_olist_orders') }}
),

items as (
    select
        order_id,
        count(*) as item_count,
        sum(item_price) as total_item_price,
        sum(freight_value) as total_freight_value,
        sum(item_price + freight_value) as expected_order_value
    from {{ ref('stg_olist_order_items') }}
    group by 1
),

payments as (
    select
        order_id,
        sum(payment_value) as total_payment_value,
        count(*) as payment_records
    from {{ ref('stg_olist_payments') }}
    group by 1
)

select
    o.order_id,
    o.customer_id,
    o.order_status,
    o.order_purchase_timestamp,
    date(o.order_purchase_timestamp) as order_purchase_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,
    coalesce(i.item_count, 0) as item_count,
    coalesce(i.total_item_price, 0) as total_item_price,
    coalesce(i.total_freight_value, 0) as total_freight_value,
    coalesce(i.expected_order_value, 0) as expected_order_value,
    coalesce(p.total_payment_value, 0) as total_payment_value,
    coalesce(p.payment_records, 0) as payment_records,
    case
        when o.order_status = 'delivered'
             and o.order_delivered_customer_date > o.order_estimated_delivery_date
        then true
        else false
    end as is_late_delivery
from orders o
left join items i using (order_id)
left join payments p using (order_id)
