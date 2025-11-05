-- Create user Colin Differ
-- Password: Bz$g%*2)G*3!vZ#a
-- Bcrypt hash: $2b$12$CqafenSsVWwvhCZxL1qAEOX/xcqZJJoQEcwYM/ORC0NcC9JSVLAj.

INSERT INTO users (
  email, 
  name, 
  password_hash, 
  email_verified, 
  inserted_at, 
  updated_at
) VALUES (
  'colin@propellernet.co.uk',
  'Colin Differ', 
  '$2b$12$CqafenSsVWwvhCZxL1qAEOX/xcqZJJoQEcwYM/ORC0NcC9JSVLAj.',
  true,
  NOW(),
  NOW()
);

-- Verify the user was created
SELECT id, email, name, email_verified, inserted_at FROM users WHERE email = 'colin@propellernet.co.uk';