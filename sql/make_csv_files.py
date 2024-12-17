# This python script make_csv_files.py generates data for 500 users to fill
# in data for each table in setup.sql. The data is loaded into sql in
# load-data.sql. The csv files generated from this file are users.csv,
# cards.csv, group_members.csv, groups.csv, locations.csv, and sports.csv.

import csv
import random
from faker import Faker
import random

faker = Faker()

NUM_USERS = 3000
NUM_LOCATIONS = 15
NUM_GROUPS = 60

# Helper function to generate random dates for birthday and preferred time
def random_date():
    return faker.date_between(start_date="-20y", end_date="today")

# helper function to generate a random day of the week; between 1 and 
# 5 days will be chosen
def random_day_of_week():
    days_of_week = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 
                    'Friday', 'Saturday', 'Sunday']
    preferred_day = random.choice(days_of_week)
    return preferred_day

# Function to make data for each table
def make_data():
    # Initialize data storage for all 6 tables
    users, sports, locations, groups, group_members, cards = [], [], [], [], [], []

    # Make Users table data
    for i in range(NUM_USERS):
        user_id = faker.uuid4() # generates a random uuid of length 36
        email = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
        while len(email) > 20:
            email = faker.unique.email()
        users.append([
            user_id,
            faker.first_name(),
            faker.last_name(),
            email,
            faker.password(length=8),
            faker.password(length=15),
            random_date(), # this is a random birthday
            faker.state_abbr(),
            faker.text(max_nb_chars=200).replace('\n', ' ')
        ])
    
    # Make Sports table data
    sports_names = ['Basketball', 'Soccer', 'Tennis', 'Running', 'Cycling', 'Volleyball',
                    'Baseball']
    for i, name in enumerate(sports_names, 1):
        sports.append([i, name])

    # Make Locations table
    location_types = ['Indoor', 'Outdoor', 'Gym', 'Park', 'Stadium', 'Field', 'Court']
    for i in range(NUM_LOCATIONS):
        locations.append([
            i + 1, # location_id
            faker.city(),
            faker.zipcode(),
            random.choice(location_types)
        ])
    
    # Make Groups table
    for i in range(NUM_GROUPS):
        location_id = random.choice(locations)[0]
        group_id = i + 1
        groups.append([
            group_id, # group_id
            random.randint(10, 20),  # max size
            location_id
        ])

        # Make Group Members table
        for _ in range(random.randint(2, 10)):  # Each group has 2-10 members
            member_user_id = random.choice(users)[0]
            group_members.append([group_id, member_user_id])

    # Make Cards table
    for user in users:
        user_id = user[0]
        sport_id = random.choice(sports)[0]
        cards.append([
            faker.uuid4(),
            user_id,
            sport_id,
            random.randint(1, 10), # Experience level of sport
            random_day_of_week() # the preferred day of meet up
            ])

    # Write data to csv files
    write_to_csv('users.csv', ['user_id', 'first_name', 'last_name', 'email', 'password', 'birthday', 'state', 'bio'], users)
    write_to_csv('sports.csv', ['sport_id', 'sport_name'], sports)
    write_to_csv('locations.csv', ['location_id', 'location_name', 'zip_code', 'location_type'], locations)
    write_to_csv('groups.csv', ['group_id', 'max_size', 'location_id'], groups)
    write_to_csv('group_members.csv', ['group_id', 'user_id'], group_members)
    write_to_csv('cards.csv', ['card_id', 'user_id', 'sports_id', 'experience_level', 'preferred_days'], cards)

def write_to_csv(filename, headers, data):
    with open(filename, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(headers)
        for row in data:
            writer.writerow(row)

make_data()