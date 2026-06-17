-- Create a limited GA4 sample table in your own raw dataset.
-- Replace YOUR_PROJECT_ID with your project.

create or replace table `YOUR_PROJECT_ID.commerce_raw.ga4_events_sample` as
select
  event_date,
  event_timestamp,
  event_name,
  user_pseudo_id,
  platform,
  device.category as device_category,
  traffic_source.source as traffic_source,
  traffic_source.medium as traffic_medium,
  ecommerce.transaction_id,
  ecommerce.purchase_revenue,
  items
from `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
where _table_suffix between '20210101' and '20210131';
