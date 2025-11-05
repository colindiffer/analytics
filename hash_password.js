const bcrypt = require('bcryptjs');

const password = "Bz$g%*2)G*3!vZ#a";
const saltRounds = 12; // Elixir's Bcrypt typically uses 12 rounds

bcrypt.hash(password, saltRounds, (err, hash) => {
  if (err) {
    console.error('Error hashing password:', err);
    process.exit(1);
  }
  
  console.log('Bcrypt hash for password:', hash);
  
  // Now we need to create the SQL statement
  const name = 'Colin Differ';
  const email = 'colin@propellernet.co.uk';
  const now = new Date().toISOString();
  
  console.log('\nSQL to create user:');
  console.log(`INSERT INTO users (email, name, password_hash, email_verified, inserted_at, updated_at) VALUES ('${email}', '${name}', '${hash}', true, '${now}', '${now}');`);
});