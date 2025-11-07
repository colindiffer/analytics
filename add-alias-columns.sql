-- Add missing ALIAS columns to sessions_v2 table
-- These are virtual columns that Plausible queries reference

ALTER TABLE plausible_events_db.sessions_v2
ADD COLUMN IF NOT EXISTS city UInt32 ALIAS city_geoname_id,
ADD COLUMN IF NOT EXISTS country LowCardinality(FixedString(2)) ALIAS country_code,
ADD COLUMN IF NOT EXISTS device LowCardinality(String) ALIAS screen_size,
ADD COLUMN IF NOT EXISTS entry_page_hostname String ALIAS hostname,
ADD COLUMN IF NOT EXISTS os LowCardinality(String) ALIAS operating_system,
ADD COLUMN IF NOT EXISTS os_version LowCardinality(String) ALIAS operating_system_version,
ADD COLUMN IF NOT EXISTS region LowCardinality(String) ALIAS subdivision1_code,
ADD COLUMN IF NOT EXISTS screen LowCardinality(String) ALIAS screen_size,
ADD COLUMN IF NOT EXISTS source String ALIAS referrer_source;
