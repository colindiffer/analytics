-- Official Plausible ClickHouse schema (modified order for dependencies)

CREATE TABLE IF NOT EXISTS plausible_events_db.ingest_counters
(
    `event_timebucket` DateTime,
    `domain` LowCardinality(String),
    `site_id` Nullable(UInt64),
    `metric` LowCardinality(String),
    `value` UInt64
)
ENGINE = SummingMergeTree(value)
ORDER BY (domain, toDate(event_timebucket), metric, toStartOfMinute(event_timebucket))
SETTINGS index_granularity = 8192;

CREATE TABLE IF NOT EXISTS plausible_events_db.sessions_v2
(
    `session_id` UInt64,
    `sign` Int8,
    `site_id` UInt64,
    `user_id` UInt64,
    `hostname` String CODEC(ZSTD(3)),
    `timestamp` DateTime CODEC(Delta(4), LZ4),
    `start` DateTime CODEC(Delta(4), LZ4),
    `is_bounce` UInt8,
    `entry_page` String CODEC(ZSTD(3)),
    `exit_page` String CODEC(ZSTD(3)),
    `pageviews` Int32,
    `events` Int32,
    `duration` UInt32,
    `referrer` String CODEC(ZSTD(3)),
    `referrer_source` String CODEC(ZSTD(3)),
    `country_code` LowCardinality(FixedString(2)),
    `screen_size` LowCardinality(String),
    `operating_system` LowCardinality(String),
    `browser` LowCardinality(String),
    `utm_medium` String CODEC(ZSTD(3)),
    `utm_source` String CODEC(ZSTD(3)),
    `utm_campaign` String CODEC(ZSTD(3)),
    `browser_version` LowCardinality(String),
    `operating_system_version` LowCardinality(String),
    `subdivision1_code` LowCardinality(String),
    `subdivision2_code` LowCardinality(String),
    `city_geoname_id` UInt32,
    `utm_content` String CODEC(ZSTD(3)),
    `utm_term` String CODEC(ZSTD(3)),
    `transferred_from` String,
    `entry_meta.key` Array(String) CODEC(ZSTD(3)),
    `entry_meta.value` Array(String) CODEC(ZSTD(3)),
    `exit_page_hostname` String CODEC(ZSTD(3)),
    `city` UInt32 ALIAS city_geoname_id,
    `country` LowCardinality(FixedString(2)) ALIAS country_code,
    `device` LowCardinality(String) ALIAS screen_size,
    `entry_page_hostname` String ALIAS hostname,
    `os` LowCardinality(String) ALIAS operating_system,
    `os_version` LowCardinality(String) ALIAS operating_system_version,
    `region` LowCardinality(String) ALIAS subdivision1_code,
    `screen` LowCardinality(String) ALIAS screen_size,
    `source` String ALIAS referrer_source,
    `country_name` String ALIAS dictGet('plausible_events_db.location_data_dict', 'name', ('country', country_code)),
    `region_name` String ALIAS dictGet('plausible_events_db.location_data_dict', 'name', ('subdivision', subdivision1_code)),
    `city_name` String ALIAS dictGet('plausible_events_db.location_data_dict', 'name', ('city', city_geoname_id)),
    `channel` LowCardinality(String),
    INDEX minmax_timestamp timestamp TYPE minmax GRANULARITY 1
)
ENGINE = VersionedCollapsingMergeTree(sign, events)
PARTITION BY toYYYYMM(start)
PRIMARY KEY (site_id, toDate(start), user_id, session_id)
ORDER BY (site_id, toDate(start), user_id, session_id)
SAMPLE BY user_id
SETTINGS index_granularity = 8192;

CREATE TABLE IF NOT EXISTS plausible_events_db.events_v2
(
    `timestamp` DateTime CODEC(Delta(4), LZ4),
    `name` LowCardinality(String),
    `site_id` UInt64,
    `user_id` UInt64,
    `session_id` UInt64,
    `hostname` String CODEC(ZSTD(3)),
    `pathname` String CODEC(ZSTD(3)),
    `referrer` String CODEC(ZSTD(3)),
    `referrer_source` String CODEC(ZSTD(3)),
    `country_code` FixedString(2),
    `screen_size` LowCardinality(String),
    `operating_system` LowCardinality(String),
    `browser` LowCardinality(String),
    `utm_medium` String CODEC(ZSTD(3)),
    `utm_source` String CODEC(ZSTD(3)),
    `utm_campaign` String CODEC(ZSTD(3)),
    `meta.key` Array(String) CODEC(ZSTD(3)),
    `meta.value` Array(String) CODEC(ZSTD(3)),
    `browser_version` LowCardinality(String),
    `operating_system_version` LowCardinality(String),
    `subdivision1_code` LowCardinality(String),
    `subdivision2_code` LowCardinality(String),
    `city_geoname_id` UInt32,
    `utm_content` String CODEC(ZSTD(3)),
    `utm_term` String CODEC(ZSTD(3)),
    `revenue_reporting_amount` Nullable(Decimal(18, 3)),
    `revenue_reporting_currency` FixedString(3),
    `revenue_source_amount` Nullable(Decimal(18, 3)),
    `revenue_source_currency` FixedString(3),
    `city` UInt32 ALIAS city_geoname_id,
    `country` LowCardinality(FixedString(2)) ALIAS country_code,
    `device` LowCardinality(String) ALIAS screen_size,
    `os` LowCardinality(String) ALIAS operating_system,
    `os_version` LowCardinality(String) ALIAS operating_system_version,
    `region` LowCardinality(String) ALIAS subdivision1_code,
    `screen` LowCardinality(String) ALIAS screen_size,
    `source` String ALIAS referrer_source,
    `country_name` String ALIAS dictGet('plausible_events_db.location_data_dict', 'name', ('country', country_code)),
    `region_name` String ALIAS dictGet('plausible_events_db.location_data_dict', 'name', ('subdivision', subdivision1_code)),
    `city_name` String ALIAS dictGet('plausible_events_db.location_data_dict', 'name', ('city', city_geoname_id)),
    `channel` LowCardinality(String)
)
ENGINE = MergeTree
PARTITION BY toYYYYMM(timestamp)
PRIMARY KEY (site_id, toDate(timestamp), name, user_id)
ORDER BY (site_id, toDate(timestamp), name, user_id, timestamp)
SAMPLE BY user_id
SETTINGS index_granularity = 8192;
