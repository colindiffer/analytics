CREATE TYPE segment_type AS ENUM ('personal', 'site');

CREATE TABLE IF NOT EXISTS segments (
    id BIGSERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type segment_type NOT NULL DEFAULT 'personal',
    segment_data JSONB NOT NULL,
    site_id BIGINT NOT NULL REFERENCES sites(id) ON DELETE CASCADE,
    owner_id BIGINT REFERENCES users(id) ON DELETE SET NULL,
    inserted_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS segments_site_id_index ON segments (site_id);
