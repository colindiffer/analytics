-- Core Plausible tables
CREATE TABLE schema_migrations (version bigint PRIMARY KEY, inserted_at timestamp DEFAULT now());

-- Users and authentication
CREATE TABLE users (
  id SERIAL PRIMARY KEY,
  email TEXT UNIQUE NOT NULL,
  password_hash TEXT,
  name TEXT,
  trial_expiry_date DATE,
  inserted_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Session salts (critical for Session.Salts module)
CREATE TABLE salts (
  id SERIAL PRIMARY KEY, 
  salt TEXT,
  inserted_at TIMESTAMP DEFAULT NOW()
);

-- Teams
CREATE TABLE teams (
  id SERIAL PRIMARY KEY,
  identifier TEXT,
  name TEXT,
  trial_expiry_date DATE,
  accept_traffic_until DATE,
  allow_next_upgrade_override BOOLEAN DEFAULT FALSE,
  locked BOOLEAN DEFAULT FALSE,
  setup_complete BOOLEAN DEFAULT FALSE,
  setup_at TIMESTAMP,
  hourly_api_request_limit INTEGER,
  notes TEXT,
  grace_period JSONB,
  inserted_at TIMESTAMP DEFAULT NOW(), 
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Sites
CREATE TABLE sites (
  id SERIAL PRIMARY KEY,
  domain TEXT NOT NULL,
  domain_changed_from TEXT,
  ingest_rate_limit_scale_seconds INTEGER,
  ingest_rate_limit_threshold INTEGER,
  team_id INTEGER REFERENCES teams(id),
  consolidated BOOLEAN DEFAULT FALSE,
  inserted_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Goals
CREATE TABLE goals (
  id SERIAL PRIMARY KEY,
  event_name TEXT,
  page_path TEXT,
  scroll_threshold INTEGER,
  display_name TEXT,
  site_id INTEGER REFERENCES sites(id),
  currency TEXT,
  inserted_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Shield rules
CREATE TABLE shield_rules_ip (
  id SERIAL PRIMARY KEY,
  inet INET,
  action TEXT,
  site_id INTEGER REFERENCES sites(id),
  inserted_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE shield_rules_country (
  id SERIAL PRIMARY KEY,
  country_code TEXT,
  action TEXT,
  site_id INTEGER REFERENCES sites(id),
  inserted_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE shield_rules_page (
  id SERIAL PRIMARY KEY,
  page_path_pattern TEXT,
  action TEXT,
  site_id INTEGER REFERENCES sites(id),
  inserted_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE shield_rules_hostname (
  id SERIAL PRIMARY KEY,
  hostname_pattern TEXT,
  action TEXT,
  site_id INTEGER REFERENCES sites(id),
  inserted_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Insert a schema migration marker
INSERT INTO schema_migrations (version, inserted_at) VALUES (20241007000001, NOW());