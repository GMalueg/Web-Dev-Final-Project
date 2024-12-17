"""
Georgia Malueg, Thierno Diallo, and Skye Ruedas
gmalueg@caltech.edu, tdiallo@caltech.edu, sruedas@caltech.edu
This program provides functionality for our athlete datamatch project.
The program aims to connect athletes with other athletes of a similar
skill level and in a similar location. Finding others to play
a sport with has never been so easy!

"""
import sys  # to print error messages to sys.stderr
import mysql.connector
# To get error codes from the connector, useful for user-friendly
# error-handling
import mysql.connector.errorcode as errorcode
from faker import Faker

# Debugging flag to print errors when debugging that shouldn't be visible
# to an actual client. ***Set to False when done testing.***
DEBUG = True


# ----------------------------------------------------------------------
# SQL Utility Functions
# ----------------------------------------------------------------------
def get_conn():
    """"
    Returns a connected MySQL connector instance, if connection is successful.
    If unsuccessful, exits.
    """
    try:
        conn = mysql.connector.connect(
          host='localhost',
          user='appadmin',
          # Find port in MAMP or MySQL Workbench GUI or with
          # SHOW VARIABLES WHERE variable_name LIKE 'port';
          port='3306',  # this may change!
          password='adminpw',
          database='db2' # replace this with your database name
        )
        print('Successfully connected.')
        return conn
    except mysql.connector.Error as err:
        # Remember that this is specific to _database_ users, not
        # application users. So is probably irrelevant to a client in your
        # simulated program. Their user information would be in a users table
        # specific to your database; hence the DEBUG use.
        if err.errno == errorcode.ER_ACCESS_DENIED_ERROR and DEBUG:
            sys.stderr('Incorrect username or password when connecting to DB.')
        elif err.errno == errorcode.ER_BAD_DB_ERROR and DEBUG:
            sys.stderr('Database does not exist.')
        elif DEBUG:
            sys.stderr(err)
        else:
            # A fine catchall client-facing message.
            sys.stderr('An error occurred, please contact the administrator.')
        sys.exit(1)

# ----------------------------------------------------------------------
# Functions for Command-Line Options/Query Execution
# ----------------------------------------------------------------------
"""
This function takes in the username and password and athenticates
that user to allow them to login.
"""
def onclick_login_query(username, password):
    cursor = conn.cursor()
    sql = 'SELECT authenticate(\'%s\', \'%s\')' % (username, password)
    try:
        cursor.execute(sql)
        row = cursor.fetchone()
        return (row) #if row = 1 login else deny login

    except mysql.connector.Error as err:
        # If you're testing, it's helpful to see more details printed.
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr(f'An error occured while trying to log you in. {err}')
"""
onclick_sign_up_query allows a new user to sign up and add data to the users table
sp_add_user is defined in setup-passwords.sql 
"""
def onclick_sign_up_query(email, password, first_name, last_name, birthday, 
                          home_location, bio, profile_url):
    cursor = conn.cursor()
    faker = Faker()
    user_id = faker.uuid4()
    sql = "CALL sp_add_user(\'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \'%s\', \
        \'%s\', \'%s\')" % (user_id, email, password, first_name, 
                            last_name, birthday, 
                            home_location, bio, 
                            profile_url)
    try:
        cursor.execute(sql)
        row = cursor.fetchone()
        return (row)

    except mysql.connector.Error as err:
        # If you're testing, it's helpful to see more details printed.
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr(f'An error occured while trying to log you in. {err}')

"""
onclick_create_card_query creates a card for a new user
sp_add_users_card is defined in setup-passwords.sql
"""
def onclick_create_card_query(user_id, sports_id, experience_level, preferred_date):
    cursor = conn.cursor()
    faker = Faker()
    card_id = faker.uuid4()
    # new user should be able to see their user_id after creating an account
    sql = "CALL sp_add_users_card(\'%s\', \'%s\', \'%s\', \'%s\', \'%s\')" % (card_id, 
                                                                              user_id, 
                                                                              sports_id, 
                                                                              experience_level, 
                                                                              preferred_date)
    try:
        cursor.execute(sql)
        row = cursor.fetchone()
        return (row)

    except mysql.connector.Error as err:
        # If you're testing, it's helpful to see more details printed.
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr(f'An error occured while trying to create your card. {err}')

"""
This function is called when the users goes online and takes in
their chosen sport catagory and returns the list of all user cards
in that category in a fromatted json to display to them.
"""
def onclick_get_card_data_query(sport_id):
    cards = []
    cursor = conn.cursor()
    sql = ' SELECT first_name, last_name, bio, preferred_date, \
            experience_level, sport_name \
            FROM users \
            JOIN cards ON users.user_id = cards.user_id \
            JOIN sports ON cards.sports_id = sports.sport_id \
            WHERE sports.sport_id = \'%s\';' % (sport_id, )
    try:
        cursor.execute(sql)
        # row = cursor.fetchone()
        rows = cursor.fetchall()
        for row in rows:
            card = {}
            (name, url, bio, availability, exper, sport) = row # tuple unpacking!
            card["name"] = name
            card["url"] = url
            card["bio"] = bio
            card["availability"] = availability
            card["experience"] = exper
            card["sport"] = sport
            cards.append(card)
        return cards
    except mysql.connector.Error as err:
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr(f'An error occurred trying to retrieve user cards: {err}')

"""
This function takes in the user id and returns a list of all available 
locations a user can play a sport alongside its distance from the user.
Distance was measured as the absolute difference between zip codes.
"""
def get_location_query(user_id):
    locations = []
    cursor = conn.cursor()
    sql = ' SELECT location_name, zip_code, location_type, \
            ABS(home_zip_code - zip_code) AS distance \
            FROM users, locations \
            WHERE user_id = \'%s\' \
            ORDER BY location_name;' % (user_id, ) 
    try:
        cursor.execute(sql)
        # row = cursor.fetchone()
        rows = cursor.fetchall()
        for row in rows:
            location = {}
            (name, zip_code, type, distance) = (row) # tuple unpacking!
            location["name"] = name
            location["zip_code"] = zip_code
            location["type"] = type
            location['distance'] = distance
            locations.append(location)
        return locations
    except mysql.connector.Error as err:
        # If you're testing, it's helpful to see more details printed.
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred retrieving your \
                       list of locations. Please try again')  

"""
This function takes in the user id and catagory returns a list of all 
locations for that sport user can play a sport alongside its distance from 
the user. Distance was measured as the absolute difference between zip codes.
"""
def get_location_filter_query(catagory, curr_user_id):
    locations = []
    cursor = conn.cursor()
    sql = ' SELECT location_name, zip_code, location_type, \
            ABS(home_zip_code - zip_code) AS distance \
            FROM users, locations  \
            WHERE user_id = \'%s\' \
            AND location_type = \'%s\' \
            ORDER BY location_name;' % (catagory, curr_user_id)
    try:
        cursor.execute(sql)
        # row = cursor.fetchone()
        rows = cursor.fetchall()
        for row in rows:
            location = {}
            (name, zip_code, type, distance) = (row) # tuple unpacking!
            location["name"] = name
            location["zip_code"] = zip_code
            location["type"] = type
            location['distance'] = distance
            locations.append(location)
        return locations
    except mysql.connector.Error as err:
        # If you're testing, it's helpful to see more details printed.
        if DEBUG:
            sys.stderr(err)
            sys.exit(1)
        else:
            sys.stderr('An error occurred,filtering your\
                        locations please try again')   

"""
This function is called when a user sends a message. It is a holder 
as message support was a stretch goal we could not reach due to scope.
"""
def send_message():
    return "Message Successfully"


# ----------------------------------------------------------------------
# Command-Line Functionality
# ----------------------------------------------------------------------

# We have not edited this command-line functionality because we are supposed
# to connect our program to a website instead of having a command line 
# application. We have kept the template code below just in case.
        

def show_options():
    """
    Displays options users can choose in the application, such as
    viewing <x>, filtering results with a flag (e.g. -s to sort),
    sending a request to do <x>, etc.
    """
    print('What would you like to do? ')
    print('  (TODO: provide command-line options)')
    print('  (x) - something nifty to do')
    print('  (x) - another nifty thing')
    print('  (x) - yet another nifty thing')
    print('  (x) - more nifty things!')
    print('  (q) - quit')
    print()
    ans = input('Enter an option: ').lower()
    if ans == 'q':
        quit_ui()
    elif ans == '':
        pass


# Another example of where we allow you to choose to support admin vs. 
# client features  in the same program, or
# separate the two as different app_client.py and app_admin.py programs 
# using the same database.
def show_admin_options():
    """
    Displays options specific for admins, such as adding new data <x>,
    modifying <x> based on a given id, removing <x>, etc.
    """
    print('What would you like to do? ')
    print('  (x) - something nifty for admins to do')
    print('  (x) - another nifty thing')
    print('  (x) - yet another nifty thing')
    print('  (x) - more nifty things!')
    print('  (q) - quit')
    print()
    ans = input('Enter an option: ').lower()
    if ans == 'q':
        quit_ui()
    elif ans == '':
        pass


def quit_ui():
    """
    Quits the program, printing a good bye message to the user.
    """
    print('Good bye!')
    exit()


def main():
    """
    Main function for starting things up.
    """
    show_options()


if __name__ == '__main__':
    # This conn is a global object that other functions can access.
    # You'll need to use cursor = conn.cursor() each time you are
    # about to execute a query with cursor.execute(<sqlquery>)
    conn = get_conn()
    main()