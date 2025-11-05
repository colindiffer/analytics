-- Additional Plausible tables needed
CREATE TABLE tracker_script_configuration (
  id SERIAL PRIMARY KEY,
  installation_type TEXT,
  track_404_pages BOOLEAN DEFAULT FALSE,
  hash_based_routing BOOLEAN DEFAULT FALSE,
  outbound_links BOOLEAN DEFAULT FALSE,
  file_downloads BOOLEAN DEFAULT FALSE,
  revenue_tracking BOOLEAN DEFAULT FALSE,
  tagged_events BOOLEAN DEFAULT FALSE,
  form_submissions BOOLEAN DEFAULT FALSE,
  pageview_props BOOLEAN DEFAULT FALSE,
  site_id INTEGER REFERENCES sites(id),
  inserted_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Add missing columns to sites table that are referenced in logs
ALTER TABLE sites ADD COLUMN IF NOT EXISTS timezone TEXT DEFAULT 'UTC';
ALTER TABLE sites ADD COLUMN IF NOT EXISTS public BOOLEAN DEFAULT FALSE;
ALTER TABLE sites ADD COLUMN IF NOT EXISTS stats_start_date DATE;
ALTER TABLE sites ADD COLUMN IF NOT EXISTS native_stats_start_at TIMESTAMP;
ALTER TABLE sites ADD COLUMN IF NOT EXISTS allowed_event_props TEXT[];
ALTER TABLE sites ADD COLUMN IF NOT EXISTS conversions_enabled BOOLEAN DEFAULT TRUE;
ALTER TABLE sites ADD COLUMN IF NOT EXISTS props_enabled BOOLEAN DEFAULT TRUE;
ALTER TABLE sites ADD COLUMN IF NOT EXISTS funnels_enabled BOOLEAN DEFAULT TRUE;
ALTER TABLE sites ADD COLUMN IF NOT EXISTS legacy_time_on_page_cutoff INTEGER;
ALTER TABLE sites ADD COLUMN IF NOT EXISTS domain_changed_at TIMESTAMP;
ALTER TABLE sites ADD COLUMN IF NOT EXISTS imported_data JSONB;