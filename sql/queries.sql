-- A query to retrieve all of the users' information 
-- with a given sports ID to form the display cards.
-- you will have to pass in the parametrers: sportID
SELECT first_name, last_name, bio, preferred_date, 
        experience_level, sport_name
FROM users
JOIN cards ON users.user_id = cards.user_id
JOIN sports ON cards.sports_id = sports.sport_id
WHERE sports.sport_id = sportID;

-- Filters the locations to only the ones that have a given location type.
-- you will have to pass in the parametrers: curr_user_id, curr_location_type
SELECT location_name, zip_code, location_type,
       ABS(home_zip_code - zip_code) AS distance
FROM users, locations
WHERE user_id = curr_user_id
AND location_type = curr_location_type
ORDER BY location_name

-- Retrieve all the loactions and their distance from the user.
-- you will have to pass in the parametrers: curr_user_id, curr_location_type
SELECT location_name, zip_code, location_type, 
       ABS(home_zip_code - zip_code) AS distance
FROM users, locations 
WHERE user_id = curr_user_id 
ORDER BY location_name;

-- Retrives emails for users for a given sport and a given level
-- This is important for personalized marketing purposes. We can use
-- this data to recommend workouts for example.
SELECT email 
FROM users 
JOIN cards ON users.user_id = cards.user_id 
WHERE cards.sports_id = desired_sport
AND cards.experience_level = desired_experience;

-- Retrieves user birthdays and emails so that we can 
-- send them a happy birthday email in their inbox
SELECT users.email
FROM users
WHERE users.birthday = DATE(NOW());

SHOW PROFILES;

-- calculates average experience level of users for each
-- sport, grouping the results by the sport's name.
SELECT sport_name, AVG(experience_level) AS avg_experience_level
FROM cards
JOIN sports ON cards.sports_id = sports.sport_id
GROUP BY sport_name;

-- retrieves the first names, last names, emails of users, and
-- the name of the sport for those interested in playing Tennis.
SELECT users.first_name, users.last_name, users.email, sports.sport_name 
FROM users
JOIN cards ON users.user_id = cards.user_id 
JOIN sports ON cards.sports_id = sports.sport_id 
WHERE sports.sport_name = 'Tennis';