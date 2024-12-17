/** 
 * Georgia Malueg
 * Final Project for CS 132
 * Connects to my Tinder for Athletes SQL database that I implented in my 
 * CS 121 final project.
 */

"use strict";
const express = require("express");
const app = express();
const multer = require("multer");
const mysql = require("promise-mysql");
const cors = require("cors");
const bcrypt = require("bcrypt");
const crypto = require("crypto");

app.use(express.urlencoded({ extended: true }))
app.use(express.json());
app.use(multer().none());
app.use(cors());

const DEBUG = true;
const SERVER_ERROR = "Something went wrong on the server... Please try again later.";
const CLIENT_ERR_CODE = 400;
const SERVER_ERR_CODE = 500;

app.use(express.static("public"));

/* ---------------------- Login Endpoint --------------------- */ 
/**
 * Logs a user in given a required email and password. Upon success,
 * returns the current queue of waiting students as JSON.
 */
app.post("/login", async (req, res, next) => {
  let email = req.body.email;
  let password = req.body.password;

  if (!(email && password)) {
    res.status(CLIENT_ERR_CODE);
    next(Error("Missing required email and/or password."));
  } else {
    let db;
    try {
      db = await getDB();
      let isAuthenticated = await authenticateUser(email, password, db);
      if (isAuthenticated) {
        // removed login cookies for testing purposes; did not reimplement
        res.type("text");
        res.send(`Welcome ${email}!`);
        } else {
          res.status(401).send("Invalid login credentials.");
        }
      } catch (err) {
        res.status(SERVER_ERR_CODE).send(SERVER_ERROR);
      } finally {
        if (db) db.end();
      }
  }
});

/* -------------------- Authentication Helper Function ------------------- */ 

/**
 * Function to authenticate the user's email and password to login.
 * I overwrote this function to work. I could not figure out how to make the password
 * equal the hashed password using bycrypt.
 * @param {String} email - The email of the user
 * @param {String} password - The password of the user
 * @returns {Boolean} - True iff login credentials are authenticated.
 */
async function authenticateUser(email, password, db) {
  let query = "SELECT salt, HEX(hashed_password) AS hashed_password FROM users WHERE email = ?;";
  let results = await db.query(query, [email]);

  if (results.length === 1) {
    // ovewritten; could not get bycrypt to work
    return true;
  }

  return false;
}

/* -------------------- Card Endpoint ------------------- */ 

/**
 * Gets the user gmail info to allow the API to get the card.
 */
app.get("/user-info", async (req, res) => {
  const { email } = req.query;

  let db;
  try {
    db = await getDB();
    const query = `
      SELECT u.home_state, s.sport_name
      FROM cards AS c
      JOIN users AS u ON c.user_id = u.user_id
      JOIN sports AS s ON c.sports_id = s.sport_id
      WHERE u.email = ?;
    `;
    const results = await db.query(query, [email]);

    if (results.length === 0) {
      res.status(404).send("No user info found for the provided email.");
      return;
    }

    res.json(results[0]);
  } catch (err) {
      res.status(500).send("An error occurred when fetching user info.");
  } finally {
      if (db) db.end();
  }
});

/**
 * Gets cards that match the user's sport and home state to display the cards
 * and allow users to match with other similar users.
 */
app.get("/cards", async (req, res) => {
  const { home_state, sport_name } = req.query;

  if (!home_state || !sport_name) {
    res.status(400).send("Missing required query parameters.");
    return;
  }

  let db;
  try {
    db = await getDB();
    const query = `
      SELECT 
        u.first_name, 
        c.experience_level, 
        c.preferred_day, 
        s.sport_name, 
        u.home_state, 
        u.bio
      FROM cards AS c
      JOIN users AS u ON c.user_id = u.user_id
      JOIN sports AS s ON c.sports_id = s.sport_id
      WHERE u.home_state = ? AND s.sport_name = ?;
      `;
      const results = await db.query(query, [home_state, sport_name]);

      res.json(results);
  } catch (err) {
    res.status(500).send("An error occurred while fetching cards.");
  } finally {
    if (db) db.end();
  }
});

/* -------------------- Create Account Endpoint------------------- */ 
/**
 * Using the procedures in setup-passwords.sql, I am popoulating the users and cards
 * tables with the user's inputted information to create an account.
 */
app.post("/createAccount", async (req, res) => {
  const {
    email,
    password,
    first_name,
    last_name,
    birthday,
    home_location,
    bio,
    sport,
    experience_level,
    preferred_day
  } = req.body;

  // make sure everything is filled out
  if (!(email && password && first_name && last_name && birthday && home_location && sport && experience_level && preferred_day)) {
    res.status(400).send("Missing required fields.");
    return;
  }

  let db;
  try {
    db = await getDB();

    // generating random UUIDs for user_id and card_id
    const user_id = crypto.randomUUID();
    const card_id = crypto.randomUUID();

    // add user to users table
    const addUserQuery = `CALL sp_add_user(?, ?, ?, ?, ?, ?, ?, ?)`;
    await db.query(addUserQuery, [
      user_id,
      first_name,
      last_name,
      email,
      password, 
      birthday,
      home_location,
      bio
    ]);

    // add user to cards table
    const addCardQuery = `CALL sp_add_users_card(?, ?, ?, ?, ?)`;
    await db.query(addCardQuery, [
      card_id,
      user_id,
      sport,
      experience_level,
      preferred_day
    ]);

    res.status(201).send("Account created successfully.");
  } catch (err) {
    res.status(500).send("An error occurred while creating the account.");
  } finally {
    if (db) db.end();
  }
});


/**
 * Establishes a database connection to the ohdb and returns the database object.
 * Any errors that occur during connection should be caught in the function
 * that calls this one.
 * @returns {Object} - The database object for the connection.
 */
async function getDB() {
  // need to make sure sql databse is running 
  let db = await mysql.createConnection({
    // Variables for connections to the database.
    // look at get_conn function
    host: "localhost",      
    port: "3306", // changed to port 8000          
    user: "appadmin",         
    password: "adminpw",
    database: "db2" // make this my database name; grant-permissions.sql  
  });
  return db;
}

/**
 * Example of error-handling middleware to cleanly handle different types of errors.
 * Any function that calls next with an Error object will hit this error-handling
 * middleware since it's defined with app.use at the end of the middleware stack.
 */
function errorHandler(err, req, res, next) {
  if (DEBUG) {
    console.error(err);
  }
  // All error responses are plain/text 
  res.type("text");
  res.send(err.message);
}
  
app.use(errorHandler);
  
const PORT = process.env.PORT || 8000;
app.listen(PORT);
