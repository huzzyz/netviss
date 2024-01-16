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

# Define the Python script and virtual environment directory
PYTHON_SCRIPT="generate_random_entries.py"
VENV_DIR="python_venv"

# Create a Python virtual environment
echo "Creating Python virtual environment..."
python3 -m venv $VENV_DIR

# Activate the virtual environment
source $VENV_DIR/bin/activate

# Install required Python packages
echo "Installing required Python packages..."
pip install psycopg2-binary bcrypt

# Check if the Python script exists
if [ -f "$PYTHON_SCRIPT" ]; then
    # Run the Python script
    echo "Running the Python script to generate random database entries..."
    python $PYTHON_SCRIPT
else
    echo "Error: Python script not found: $PYTHON_SCRIPT"
fi

# Deactivate the virtual environment
deactivate

echo "Script execution completed."
