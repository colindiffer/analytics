CREATE DATABASE IF NOT EXISTS plausible;

CREATE TABLE IF NOT EXISTS plausible.page_agg
(
  site_id UInt32,
  domain String,
  page_path String,
  event_date Date,
  channel LowCardinality(String),
  referrer_domain LowCardinality(String),
  country_code FixedString(2),
  device_category LowCardinality(String),

  pageviews UInt64,
  sessions UInt64,
  bounces UInt64,
  total_duration_seconds UInt64,
  revenue_cents UInt64,
  transactions UInt64,
  products UInt64
)
ENGINE = SummingMergeTree()
PARTITION BY toYYYYMM(event_date)
ORDER BY (site_id, event_date, page_path, channel, referrer_domain, country_code, device_category);
