-- Create site_imports table for Plausible
CREATE TABLE IF NOT EXISTS site_imports (
  id SERIAL PRIMARY KEY,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  source TEXT NOT NULL,
  status TEXT NOT NULL,
  legacy BOOLEAN NOT NULL DEFAULT TRUE,
  label TEXT,
  has_scroll_depth BOOLEAN NOT NULL DEFAULT FALSE,
  site_id INTEGER NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
  imported_by_id INTEGER REFERENCES users(id) ON DELETE SET NULL,
  inserted_at TIMESTAMP NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

-- Create indexes
CREATE INDEX IF NOT EXISTS site_imports_site_id_start_date_index ON site_imports(site_id, start_date);
CREATE INDEX IF NOT EXISTS site_imports_imported_by_id_index ON site_imports(imported_by_id);
