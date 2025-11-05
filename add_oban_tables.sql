-- Add missing Oban tables for job processing
CREATE TABLE oban_jobs (
  id SERIAL PRIMARY KEY,
  state TEXT NOT NULL DEFAULT 'available',
  queue TEXT NOT NULL DEFAULT 'default',
  worker TEXT NOT NULL,
  args JSONB NOT NULL DEFAULT '{}',
  errors JSONB[] DEFAULT '{}',
  attempt INTEGER NOT NULL DEFAULT 0,
  max_attempts INTEGER NOT NULL DEFAULT 20,
  inserted_at TIMESTAMP DEFAULT NOW(),
  scheduled_at TIMESTAMP DEFAULT NOW(),
  attempted_at TIMESTAMP,
  completed_at TIMESTAMP,
  attempted_by TEXT[],
  discarded_at TIMESTAMP,
  priority INTEGER DEFAULT 0,
  tags TEXT[] DEFAULT '{}',
  meta JSONB DEFAULT '{}',
  cancelled_at TIMESTAMP,
  CONSTRAINT oban_jobs_args_check CHECK (jsonb_typeof(args) = 'object'),
  CONSTRAINT oban_jobs_errors_check CHECK (array_ndims(errors) IS NULL OR array_ndims(errors) = 1),
  CONSTRAINT oban_jobs_meta_check CHECK (jsonb_typeof(meta) = 'object')
);

CREATE INDEX IF NOT EXISTS oban_jobs_state_queue_priority_scheduled_at_id_index 
ON oban_jobs (state, queue, priority DESC, scheduled_at, id);

CREATE INDEX IF NOT EXISTS oban_jobs_args_index ON oban_jobs USING gin (args);
CREATE INDEX IF NOT EXISTS oban_jobs_meta_index ON oban_jobs USING gin (meta);
CREATE INDEX IF NOT EXISTS oban_jobs_inserted_at_index ON oban_jobs (inserted_at);

-- Oban peers table for distributed processing
CREATE TABLE oban_peers (
  name TEXT NOT NULL,
  node TEXT NOT NULL,
  started_at TIMESTAMP NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMP NOT NULL DEFAULT NOW() + INTERVAL '60 seconds',
  PRIMARY KEY (name, node)
);

-- Additional user-related tables that might be missing
CREATE TABLE IF NOT EXISTS user_sessions (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  token TEXT NOT NULL,
  inserted_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS api_keys (
  id SERIAL PRIMARY KEY,
  name TEXT,
  key_hash TEXT NOT NULL,
  key_prefix TEXT NOT NULL,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  scopes TEXT[] DEFAULT '{}',
  hourly_request_limit INTEGER,
  inserted_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Site memberships for user access
CREATE TABLE IF NOT EXISTS site_memberships (
  id SERIAL PRIMARY KEY,
  site_id INTEGER REFERENCES sites(id) ON DELETE CASCADE,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'viewer',
  inserted_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(site_id, user_id)
);