#!/bin/bash

# Variables
DB_NAME="netviss"
DB_USER="ali"
DB_PASSWORD="ali123"

# Login to PostgreSQL and execute the following commands
sudo -u postgres psql <<EOF

-- Create a new user
CREATE USER $DB_USER WITH PASSWORD '$DB_PASSWORD';

-- Create a new database
CREATE DATABASE $DB_NAME;

-- Grant all privileges of the database to the user
GRANT ALL PRIVILEGES ON DATABASE $DB_NAME TO $DB_USER;

-- Connect to the newly created database
\c $DB_NAME

-- Create the 'users' table
CREATE TABLE users (
    full_name VARCHAR(255),
    username VARCHAR(255),
    auth_type VARCHAR(50),
    password VARCHAR(255),
    status INT
);

EOF

echo "Database and user have been created, and table 'users' has been set up."
