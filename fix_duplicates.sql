-- Find duplicate sites
SELECT domain, COUNT(*) as count 
FROM sites 
WHERE domain = 'propellernet.co.uk'
GROUP BY domain;

-- Keep only the oldest one, delete the rest
DELETE FROM sites 
WHERE domain = 'propellernet.co.uk' 
AND id NOT IN (
  SELECT MIN(id) 
  FROM sites 
  WHERE domain = 'propellernet.co.uk'
);

-- Verify only one remains
SELECT id, domain, inserted_at FROM sites WHERE domain = 'propellernet.co.uk';
