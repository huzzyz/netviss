#!/bin/bash

# Update system's package index
echo "Updating system's package index..."
sudo apt-get update

# Install PostgreSQL and its dependencies
echo "Installing PostgreSQL..."
sudo apt-get install -y postgresql postgresql-contrib

# Install pip for Python 3
echo "Installing pip for Python 3..."
sudo apt-get install -y python3-pip

# Install virtualenv
echo "Installing virtualenv..."
sudo apt-get install -y python3-venv

# Define the virtual environment directory
VENV_DIR="python_venv"

# Create a Python virtual environment
echo "Creating Python virtual environment..."
python3 -m venv $VENV_DIR

# Activate the virtual environment
source $VENV_DIR/bin/activate

# Install bcrypt using pip
echo "Installing bcrypt..."
pip install bcrypt

# Deactivate the virtual environment
deactivate

echo "PostgreSQL installation and Python setup with bcrypt completed."
