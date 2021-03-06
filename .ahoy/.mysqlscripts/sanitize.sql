-- 
-- Scrub important information from a Drupal database.
-- 

-- Remove all email addresses.
UPDATE users SET mail=CONCAT('user', uid, '@example.com'), init=CONCAT('user', uid, '@example.com') WHERE uid != 0;

-- Example: Disable a module by setting its system.status value to 0.
-- UPDATE system SET status = 0 WHERE name = 'securepages';

-- Example: Update or delete variables via the variable table.
-- DELETE FROM variable WHERE name='secret_key';
-- Note that to update variables the value must be a properly serialized php array.
-- UPDATE variable SET value='s:24:"http://test.gateway.com/";' WHERE name='payment_gateway';

-- IMPORTANT: If you change the variable table, clear the variables cache.
-- DELETE FROM cache WHERE cid = 'variables';

-- Scrub url aliases for non-admins since these also reveal names
-- Add the IGNORE keyword, since a user may have multiple aliases, and without
-- this keyword the attempt to store duplicate dst values causes the query to fail.
-- UPDATE IGNORE url_alias SET dst = CONCAT('users/', REPLACE(src,'/', '')) WHERE src IN (SELECT CONCAT('user/', u.uid) FROM users u WHERE u.uid NOT IN (SELECT uid FROM users_roles WHERE rid=3) AND u.uid > 0);

-- don't leave e-mail addresses, etc in comments table.
-- UPDATE comments SET name='Anonymous', mail='', homepage='http://example.com' WHERE uid=0;

-- Scrub webform submissions.
-- UPDATE webform_submitted_data set data='*scrubbed*';

-- remove sensitive customer data from custom module
-- TRUNCATE custom_customer_lead_data;

-- USER PASSWORDS
-- These statements assume you want to preserve real passwords for developers. Change 'rid=3' to the 
-- developer or test role you want to preserve.

-- DRUPAL 6
-- Remove passwords unless users have 'developer role'
UPDATE users SET pass=md5('devpassword') WHERE uid IN (SELECT uid FROM users_roles WHERE rid=3) AND uid > 0;

-- Admin user should not be same but not really well known
UPDATE users SET pass = MD5('supersecret!') WHERE uid = 1;

-- DRUPAL 7
-- Drupal 7 requires sites to generate a hashed password specific to their site. A script in the 
-- docroot/scripts directory is provided for doing this. From your docroot run the following:
--      
--    scripts/password-hash.sh password
--
-- this will generate a hash for the password "password". In the following statements replace
-- $REPLACE THIS$ with your generated hash.

-- Remove passwords unless users have 'developer role'
UPDATE users SET pass='123' WHERE uid IN (SELECT uid FROM users_roles WHERE rid=3) AND uid > 0;

-- Admin user should not be same but not really well known
UPDATE users SET pass='1235' WHERE uid = 1;

TRUNCATE flood;
TRUNCATE history;
TRUNCATE sessions;
TRUNCATE watchdog;

SELECT concat('TRUNCATE TABLE ', TABLE_NAME, ';') FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE 'access%';

SELECT concat('TRUNCATE TABLE ', TABLE_NAME, ';') FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE 'devel_%';

SELECT concat('TRUNCATE TABLE ', TABLE_NAME, ';') FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE 'cache%';

SELECT concat('TRUNCATE TABLE ', TABLE_NAME, ';') FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE 'migrate_%';

SELECT concat('TRUNCATE TABLE ', TABLE_NAME, ';') FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME LIKE 'search_%';
