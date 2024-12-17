DELIMITER !

DROP FUNCTION IF EXISTS get_experience_level_label;
DROP PROCEDURE IF EXISTS add_new_sport;
DROP TRIGGER IF EXISTS verify_age;

CREATE FUNCTION get_experience_level_label(experience_level INT) RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
  DECLARE level_label VARCHAR(20);

  CASE 
    WHEN experience_level BETWEEN 1 AND 3 THEN 
      SET level_label = 'Beginner';
    WHEN experience_level BETWEEN 4 AND 7 THEN 
      SET level_label = 'Intermediate';
    WHEN experience_level BETWEEN 8 AND 10 THEN 
      SET level_label = 'Advanced';
  END CASE;
  
  RETURN level_label;
END !


-- adds a new sport to the sports table if it doesn't already exist. This procedure checks for
-- existence of sport by name and uses a SIGNAL statement to raise error if the sport already existss
CREATE PROCEDURE add_new_sport(IN new_sport_name VARCHAR(30))
BEGIN
  -- Check if the sport already exists to avoid duplicates
  IF NOT EXISTS (SELECT * FROM sports WHERE sport_name = new_sport_name) THEN
    INSERT INTO sports(sport_name) VALUES (new_sport_name);
  ELSE
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Sport already exists.';
  END IF;
END !

DELIMITER !

-- checks if new user is at least 18 years old before allowing them to be added to the users table
-- if not, it prevents insert and shows a message saying the user must be at least 18
CREATE TRIGGER verify_age
BEFORE INSERT ON users
FOR EACH ROW
BEGIN
    IF TIMESTAMPDIFF(YEAR, NEW.birthday, CURDATE()) < 18 
    OR (TIMESTAMPDIFF(YEAR, NEW.birthday, CURDATE()) = 18 AND DATE_FORMAT(CURDATE(), '%m-%d') < DATE_FORMAT(NEW.birthday, '%m-%d')) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'User is not old enough. Must be at least 18 years old.';
    END IF;
END !

DELIMITER ;