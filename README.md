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
   - Query Parameters:
      - home_state (required): The user's home state
      - sport_name (required): The sport the user is interested in finding other people to play with
   - Example response:
   - JSON
        {
          "first_name": "Georgia",
          "last_name": "Malueg",
          "sport": "Soccer",
          "experience_level": 2,
          "preferred_day": "Monday",
          "home_state": "FL",
          "bio": "I am a student in CS 132."
        }
   - Error handling:
      - 400 Bad Request: if parameters are missing
      - 500 Internal Server Error: if there are database issues
2. GET /user-info
   - Description: Get the logged-in user's home state and chosen sport based on their email
   - Query Parameters:
       - email (required): The user's email
   - Response: JSON object that contains home_state and sport_name.
   - Example Request: GET /user-info?email=gmalueg@gmail.com
   - Example response:
   - JSON
     {
        "home_state": "CA",
        "sport_name": "Soccer"
     }
   - Error handling:
      - 400 Bad Request: if the email parameter is missing
      - 404 Not Found: if there isn't data found for the given email
      - 500 Internal Server Error: if there are database issues
4. POST /login
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
      - 400 Bad Request: if required fields are missing
      - 401 Unauthorized: if credentials are not valid
  
5. POST /createAccount
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
      - 400 Bad Request: if required fields are missing

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
