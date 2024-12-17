-- CS 121 Final Project
-- load-data.sql loads data from the csv files for each table into the tables.
-- the csv files are titled users.csv, cards.csv, group_members.csv, groups.csv
-- locations.csv, and sports.csv.

SET GLOBAL local_infile = 'ON';

-- load data for users table
LOAD DATA LOCAL INFILE 'users.csv' INTO TABLE users
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

-- load data for sports table
LOAD DATA LOCAL INFILE 'sports.csv' INTO TABLE sports
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

-- load data for locations table
LOAD DATA LOCAL INFILE 'locations.csv' INTO TABLE locations
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

-- load data for groups table
LOAD DATA LOCAL INFILE 'groups.csv' INTO TABLE formed_groups
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

-- load data for group_members table
LOAD DATA LOCAL INFILE 'group_members.csv' INTO TABLE group_members
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;

-- load data for cards table
LOAD DATA LOCAL INFILE 'cards.csv' INTO TABLE cards
FIELDS TERMINATED BY ',' ENCLOSED BY '"' LINES TERMINATED BY '\r\n' IGNORE 1 ROWS;