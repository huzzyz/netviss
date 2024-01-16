import psycopg2
from faker import Faker
import random
import bcrypt

# Initialize Faker for data generation
fake = Faker()

# Database connection parameters
db_name = "netviss"
user = "ali"  # replace with your PostgreSQL username
password = "ali321"  # replace with your PostgreSQL password
host = "localhost"  # or your database host
port = "5432"  # or your database port

# Connect to your database
conn = psycopg2.connect(dbname=db_name, user=user, password=password, host=host, port=port)
cur = conn.cursor()

# Number of random entries to create
num_entries = 100

for _ in range(num_entries):
    full_name = fake.name()
    username = fake.user_name()
    auth_type = random.choice(['local', 'oauth', 'sso'])
    
    # Generate a random password and hash it using bcrypt
    raw_password = fake.password()
    hashed_password = bcrypt.hashpw(raw_password.encode('utf-8'), bcrypt.gensalt(10))

    status = random.randint(0, 1)  # Randomly choosing between 0 and 1

    # Inserting the data into the database
    cur.execute("INSERT INTO users (full_name, username, auth_type, password, status) VALUES (%s, %s, %s, %s, %s)",
                (full_name, username, auth_type, hashed_password, status))

# Commit changes and close connection
conn.commit()
cur.close()
conn.close()
