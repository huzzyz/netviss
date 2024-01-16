import psycopg2
from faker import Faker
import random
import bcrypt

# Initialize Faker for data generation
fake = Faker()

# Database connection parameters
db_name = "netviss"
user = "postgres"  # Replace with your PostgreSQL username
password = "postgres321"  # Replace with your PostgreSQL password
host = "localhost"  # Or your database host
port = "5432"  # Or your database port

# Connect to your database
conn = psycopg2.connect(dbname=db_name, user=user, password=password, host=host, port=port)
cur = conn.cursor()

# Number of random entries to create
num_entries = 10

for _ in range(num_entries):
    full_name = fake.name()
    username = fake.user_name()
    auth_type = random.choice(['local', 'oauth', 'sso'])
    
    # Generate a random password and hash it using bcrypt with a salt round of 10
    raw_password = fake.password()
    hashed_password = bcrypt.hashpw(raw_password.encode('utf-8'), bcrypt.gensalt(10)).decode('utf-8')

    # Randomly assign a status of either 0 or 1
    status = random.randint(0, 1)

    # Inserting the data into the database
    cur.execute("INSERT INTO users (full_name, username, auth_type, password, status) VALUES (%s, %s, %s, %s, %s)",
                (full_name, username, auth_type, hashed_password, status))

# Commit changes and close connection
conn.commit()
cur.close()
conn.close()
