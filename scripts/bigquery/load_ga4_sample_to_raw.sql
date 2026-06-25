CREATE OR REPLACE TABLE `governed-ai-commerce-analyst.commerce_raw_us.ga4_events_sample`
PARTITION BY event_date_dt
CLUSTER BY event_name
AS
SELECT
  PARSE_DATE('%Y%m%d', event_date) AS event_date_dt,
  TIMESTAMP_MICROS(event_timestamp) AS event_timestamp_ts,
  event_date,
  event_timestamp,
  event_name,
  user_pseudo_id,
  platform,
  device,
  geo,
  traffic_source,
  ecommerce,
  items,
  event_params
FROM
  `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
LIMIT 10000;