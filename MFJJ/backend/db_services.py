import psycopg2
import os
import math

def init_db():
    # Replace these with your actual database credentials
    connection = psycopg2.connect(
        dbname="railway",
        user="postgres",
        password="LVGZNTsafcfvPASxHgQZbRRMBaXVrKtM",
        host="postgres.railway.internal",  # for example, "db.example.com"
        port="5432"  # default PostgreSQL port is 5432
    )

    if not os.path.exists("locations.db"):
        connection = sqlite3.connect("locations.db")
        cursor = connection.cursor()
        cursor.execute('''
                       
                        CREATE TABLE IF NOT EXISTS locations (
                        id INTEGER PRIMARY KEY AUTOINCREMENT,
                        user_id TEXT NOT NULL,
                        latitude REAL NOT NULL,
                        longitude REAL NOT NULL
                        )
                       ''')
        connection.commit()
        connection.close()

def add_location_item(data):
    # getting the form items sent from client
    user_id = data['user_id']
    latitude = data['lat']
    longitutde = data['long']


    # connecting with the database
    connection = sqlite3.connect("locations.db")
    cursor = connection.cursor()
    cursor.execute('''
                    INSERT INTO locations (user_id, latitude, longitude)
                    VALUES (?, ?, ?)
                    ''', (user_id, latitude, longitutde))
    connection.commit()
    connection.close()

# Haversine formula to calculate distance between two latitude/longitude pairs
def haversine(lat1, lon1, lat2, lon2):
    R = 6371.0  # Earth radius in kilometers
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = math.sin(dlat / 2) ** 2 + math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * math.sin(dlon / 2) ** 2
    c = 2 * math.asin(math.sqrt(a))
    return R * c

def get_proximate_users(data):
    # A DIFFERENCE OF 0.1km
    MAX_DISTANCE = 0.1
    user_lat = float(data['lat'])
    user_long = float(data['long'])
    # connecting with the database
    connection = sqlite3.connect("locations.db")
    cursor = connection.cursor()
    # grab all longitude and latitude locations for all users
    cursor.execute("SELECT user_id, latitude, longitude from LOCATIONS")
    locations = cursor.fetchall()
    connection.close()

    # calculate nearby users
    nearby_users = []
    for user_id, latitude, longitutde in locations: 
        distance = haversine(user_lat, user_long, latitude, longitutde)
        if distance <= MAX_DISTANCE:
            # GET USER INTERESTS FROM DB
            nearby_users.append({"username": user_id})
    return nearby_users