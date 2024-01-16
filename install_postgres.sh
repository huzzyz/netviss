#!/bin/bash

# Update system's package index
sudo apt-get update

# Install PostgreSQL and its dependencies
sudo apt-get install -y postgresql postgresql-contrib

# Install pip for Python 3
sudo apt-get install -y python3-pip

# Install bcrypt using pip
pip3 install bcrypt
