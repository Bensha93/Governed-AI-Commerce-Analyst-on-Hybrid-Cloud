# Data Dictionary

## Olist source entities

| Entity | Description |
|---|---|
| orders | Order lifecycle, status, purchase timestamp, delivery timestamps |
| order_items | Product, seller, item price, freight value per order item |
| payments | Payment type, installments, payment value |
| customers | Customer identifiers and location fields |
| products | Product metadata and category |
| sellers | Seller identifiers and location fields |
| reviews | Review score and review timestamps |

## GA4 source entities

| Entity | Description |
|---|---|
| events | E-commerce web/app events such as page view, view item, add to cart, purchase |
| users | Obfuscated users and event-level attributes |
| traffic | Source/medium/campaign attributes |
| items | Product/item attributes nested inside e-commerce events |

## Certified AI views

| View | Purpose |
|---|---|
| vw_customer_journey | Funnel and customer journey analytics |
| vw_order_reconciliation | Order/payment/freight reconciliation status |
| vw_revenue_performance | Revenue by month/category/seller |
| vw_delivery_performance | Delivery SLA and late delivery analysis |
| vw_product_performance | Product category performance |
