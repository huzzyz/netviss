#!/bin/bash

# Variables
DB_NAME="netviss"
TABLE_NAME="users"

# Create Database with UTF-8 encoding
createdb --encoding=UTF8 --template=template0 --lc-collate='en_US.utf8' --lc-ctype='en_US.utf8' $DB_NAME

# Connect to Database and Execute SQL Commands
psql $DB_NAME << EOF

-- Create table
CREATE TABLE $TABLE_NAME (
    full_name VARCHAR(255),
    username VARCHAR(255),
    auth_type VARCHAR(50),
    password VARCHAR(255),
    status INT
);

-- Insert sample data
INSERT INTO $TABLE_NAME (full_name, username, auth_type, password, status) VALUES ('John Doe', 'johndoe', 'local', 'password123', 1);

-- Run SELECT query
SELECT full_name, username, auth_type, password FROM $TABLE_NAME WHERE status = 1;

EOF
