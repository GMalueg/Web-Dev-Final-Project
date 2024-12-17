-- Final Project DDL for Athlete Match
-- Group members: Georgia Malueg, Skye Ruedas, and Thierno Diallo

DROP TABLE IF EXISTS cards;
DROP TABLE IF EXISTS group_members;
DROP TABLE IF EXISTS formed_groups;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS sports;
DROP TABLE IF EXISTS locations;

-- Users table to store personal details of users and login credentials.
CREATE TABLE users (
    -- using faker uuid v4 which generates a random uuid of length 36
    user_id CHAR(36) PRIMARY KEY,
     -- no two users should have the same email
    first_name VARCHAR(20) NOT NULL,
    last_name VARCHAR(20),
    email VARCHAR(20) UNIQUE NOT NULL,
    salt CHAR(8) NOT NULL, -- salt to hash the password
    hashed_password BINARY(64) NOT NULL, -- inputted password hashed
    birthday DATE,
    home_state CHAR(5), -- changed from home zip code
    bio VARCHAR(200)
    -- removed url to profile
);

-- Location table of different locations that groups can go to for sports.
-- Ask El about if it's worth to specify a specific sport per location.
CREATE TABLE locations (
    location_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    location_name VARCHAR(50),
    zip_code CHAR(5), 
    -- the location types are Indoor, Outdoor, Gym, Park, Stadium, Field, and Court
    location_type VARCHAR(15) NOT NULL DEFAULT 'Outdoor'
);

-- Sports table to list the sports on the app and the sport's corresponding id
-- Sports included are basektbal, soccer, tennis, running, cycling, volleyball
-- and baseball.
CREATE TABLE sports (
    -- Basketball: 1, Soccer: 2, Tennis: 3, Running: 4, Cycling: 5,
    -- Volleyball: 6, Baseball: 7 are the corresponding sport_ids
    sport_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
    -- the same sport should not have different sports_ids
    sport_name VARCHAR(30) UNIQUE NOT NULL
);

-- Groups table created by users to arrange sport events. Table contains info
-- on max size, location, members, and group id. 
CREATE TABLE formed_groups (
    group_id INT UNSIGNED PRIMARY KEY AUTO_INCREMENT,
     -- was orignally type auto increment int but doesn't really make sense
    max_size INT, -- max size is randomly generated between 5 and 20
    location_id INT UNSIGNED NOT NULL,
    FOREIGN KEY (location_id) REFERENCES locations(location_id) ON DELETE CASCADE
);

-- New group_members table relating each user to a group; a user can be in
-- several groups; group_id and user_id are both primary keys so the entry 
-- isn't repeated; relationship set. Groups will have between 2 and 5
-- members in our data set.
CREATE TABLE group_members (
    group_id INT UNSIGNED,
    user_id VARCHAR(36),
    PRIMARY KEY (group_id, user_id),
    FOREIGN KEY (group_id) REFERENCES formed_groups(group_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Cards table contains the user's preferences for sports, their experience
-- level, and preferred time
CREATE TABLE cards (
    card_id CHAR(36) PRIMARY KEY, -- generated with faker uuid v4
    user_id CHAR(36) NOT NULL,
    sports_id INT UNSIGNED NOT NULL,
    experience_level INT, -- a range of 1 to 10 based on skill level; 10 is highest skill level
    preferred_day ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday') NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (sports_id) REFERENCES sports(sport_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- I chose email as an index because it can easily be used for fast lookups
CREATE INDEX email_idx ON users(email);