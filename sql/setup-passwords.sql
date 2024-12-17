-- (Provided) This function generates a specified number of characters for using as a
-- salt in passwords.
DELIMITER !
CREATE FUNCTION make_salt(num_chars INT)
RETURNS VARCHAR(20) DETERMINISTIC
BEGIN
    DECLARE salt VARCHAR(20) DEFAULT '';

    -- Don't want to generate more than 20 characters of salt.
    SET num_chars = LEAST(20, num_chars);

    -- Generate the salt!  Characters used are ASCII code 32 (space)
    -- through 126 ('z').
    WHILE num_chars > 0 DO
        SET salt = CONCAT(salt, CHAR(32 + FLOOR(RAND() * 95)));
        SET num_chars = num_chars - 1;
    END WHILE;

    RETURN salt;
END !
DELIMITER ;

-- Adds a new user to the user_info table, using the specified password (max
-- of 20 characters). Salts the password with a newly-generated salt value,
-- and then the salt and hash values are both stored in the table.
DELIMITER !
CREATE PROCEDURE sp_add_user(user_id VARCHAR(36), 
                            first_name VARCHAR(20),
                            last_name VARCHAR(20),
                            email VARCHAR(20),
                            password VARCHAR(20),
                            birthday DATE,
                            home_location VARCHAR(100),
                            bio VARCHAR(200))
BEGIN
  DECLARE salt CHAR(8) DEFAULT make_salt(8);
  DECLARE password_hash BINARY(64) DEFAULT SHA2(CONCAT(salt, password), 256);
  
  INSERT INTO users
  VALUES (user_id, first_name, last_name, email, salt, password_hash, birthday, 
          home_location, bio);
END !
DELIMITER ;

-- Adds a new user's info into the cards table; this procedure should be executed after sp_add_user is
DELIMITER !
CREATE PROCEDURE sp_add_users_card(card_id CHAR (36), user_id CHAR(36), sports_id INT, experience_level INT, preferred_day ENUM('Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'))
BEGIN 
  INSERT INTO cards
  VALUES (card_id, user_id, sports_id, experience_level, preferred_day);
END !
DELIMITER ;

-- Authenticates the specified username and password against the data
-- in the user_info table.  Returns 1 if the user appears in the table, and the
-- specified password hashes to the value for the user. Otherwise returns 0.
DELIMITER !
CREATE FUNCTION authenticate(email VARCHAR(20), password VARCHAR(36))
RETURNS TINYINT DETERMINISTIC
BEGIN
  DECLARE curr_salt CHAR(8);
  DECLARE curr_hash BINARY(64);
  DECLARE new_hash BINARY(64);

  IF (email NOT IN (SELECT email FROM users))
    THEN RETURN 0;
  END IF;

  SELECT salt, hashed_password 
  INTO curr_salt, curr_hash
  FROM users
  WHERE users.email = email;

  SET new_hash = SHA2(CONCAT(curr_salt, password), 256);

  IF (curr_hash = new_hash)
    THEN RETURN 1;
  ELSE RETURN 0;
  END IF;
END !
DELIMITER ;

-- Create a procedure sp_change_password to generate a new salt and change the given
-- user's password to the given password (after salting and hashing)
DELIMITER !
CREATE PROCEDURE sp_change_password(
  username VARCHAR(20), new_password VARCHAR(36))
BEGIN
  DECLARE new_salt CHAR(8);
  DECLARE hashed_password BINARY(64);
  SET new_salt = make_salt(8);
  SET hashed_password = SHA2(CONCAT(new_salt, new_password), 256);

  UPDATE user_info
  SET salt = new_salt, password_hash = hashed_password
  WHERE user_info.username = username;
END !
DELIMITER ;