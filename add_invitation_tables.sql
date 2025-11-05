-- Add missing invitation and transfer tables
CREATE TABLE team_invitations (
  id SERIAL PRIMARY KEY,
  invitation_id TEXT UNIQUE NOT NULL,
  email TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'viewer',
  team_id INTEGER REFERENCES teams(id) ON DELETE CASCADE,
  inviter_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  inserted_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE invitations (
  id SERIAL PRIMARY KEY,
  invitation_id TEXT UNIQUE NOT NULL,
  email TEXT NOT NULL,
  role TEXT NOT NULL DEFAULT 'owner',
  site_id INTEGER REFERENCES sites(id) ON DELETE CASCADE,
  inviter_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  inserted_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE site_transfers (
  id SERIAL PRIMARY KEY,
  transfer_id TEXT UNIQUE NOT NULL,
  email TEXT NOT NULL,
  site_id INTEGER REFERENCES sites(id) ON DELETE CASCADE,
  initiator_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  inserted_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Add email verification table
CREATE TABLE email_verification_codes (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  code TEXT NOT NULL,
  issued_at TIMESTAMP DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Add enterprise features table (might be referenced)
CREATE TABLE enterprise_plans (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
  team_id INTEGER REFERENCES teams(id) ON DELETE CASCADE,
  paddle_plan_id TEXT,
  paddle_subscription_id TEXT,
  status TEXT DEFAULT 'active',
  billing_interval TEXT DEFAULT 'monthly',
  last_bill_date DATE,
  next_bill_date DATE,
  inserted_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Add missing columns to users table that might be needed
ALTER TABLE users ADD COLUMN IF NOT EXISTS email_verified BOOLEAN DEFAULT FALSE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS notes TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS accept_traffic_until DATE;
ALTER TABLE users ADD COLUMN IF NOT EXISTS previous_email TEXT;