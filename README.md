# CS 132 Web Development Final Project: Tinder for Athletes

## Overview
This project implements the Tinder for Athletes API and front end website to create an experience for user's to find other athletes to play sports with. Not all aspects of the implemented databse are currently used, and the project will be further implemented in the future to implement a group and chat feature.

## API Documentation
1. GET /cards
   - Description: Retrieve a list of all cards in the database.
   - Returned data format: JSON
   - Query Parameters:
       - home_state (required): the user's home state
       - preferred_day (required): the user's preferred day to play sports
   - Response: JSON array of card objects. A card will appear on the user's screen.
   - Example response:
   - Error handling:

2. POST /login
   - Description: Submit a login request.
   - Request Body:
       - email (required): the user's gmail used to login.
       - password (required): the user's password to login.
   - Response: Redirect to page where you swipe on users cards.
   - Example Request: /login
      - POST body parameters:
         - email='gmalueg@caltech.edu'
         - password='pass'
   - Error handling:
  
3. POST /createAccount
   - Description: Submit user and card information to create an account.
   - Request Body:
       - first_name (required): user's first name
       - last_name (required): user's last name
       - email (required): user's email
       - password (required): user's password
       - birthday (required): user's birthday
       - home_state (required): user's home day
       - sport (required): the sport the user is looking to find people to play with
       - experience_level (required): experience level in the given sport (range of 1-10)
       - preferred_day (required): the preferred day of the week to meet up to play the sport (Monday, Tuesday, ...)
       - bio (optional): user's bio
   - Response: Success message.
   - Example Request: /createAccount
      - POST body parameters:
         - first_name='Georgia'
         - last_name='Malueg'
         - email='gmalueg@caltech.edu'
         - password='pass'
         - birthday='11-24-2002'
         - home_state='FL'
         - sport='Soccer'
         - experience_level='2'
         - preferred_day='Monday'
         - bio='I am a student in CS 132.'
   - Error handling:

## File Structure
```
final-project/
├── public/
│   ├── index.html           # the main page for logging into tinder for athletes
│   ├── styles.css           # front-end styles for index.html
│   ├── signup.html
│   ├── signup-styles.css
│   ├── cards.html
│   ├── cards-styles.css
│   ├── functionality.js
│   ├── utils.js
├── app.js
├── data/
│   ├── users.csv
│   └── cards.csv
│   └── sports.csv
├── sql/
│   ├── setup.sql
│   └── load-data.sql
│   └── setup-passwords.sql
│   └── grant-permissions.sql
│   └── queries.sql
│   └── setup-routines.sql
│   └── make_csv_files.py
└── package.json                 # Node.js project configuration
```
## Authors
Georgia Malueg is the sole contributer to all html, css, and javascript files. The SQL database was built collaboratively with Georgia Malueg, Skye Ruedas, and Thierno Diallo.
