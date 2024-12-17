-- To see all of the users in your mysql settings:
SELECT user FROM mysql.user;

-- To create users with passwords (locally) (can also set up this up on phpMyAdmin or Workbench)
CREATE USER 'appadmin'@'localhost' IDENTIFIED BY 'adminpw';
CREATE USER 'appclient'@'localhost' IDENTIFIED BY 'clientpw';
-- See the default privileges for users
SELECT user, execute_priv FROM mysql.user;

-- Admins can do all the things
GRANT ALL PRIVILEGES ON *.* TO 'appadmin'@'localhost';
-- Clients (e.g. app developers interacting with the database) may only have SELECT
-- privileges granted
GRANT SELECT ON db2.* TO 'appclient'@'localhost';

-- Flush the GRANT commands to update the privileges
FLUSH PRIVILEGES;

-- Let's see the results!
SELECT user, execute_priv FROM mysql.user WHERE user LIKE 'app%';
-- Now, only airbnbadmin has admin privileges, airbnbclient only has SELECT privileges (e.g. no procedures)