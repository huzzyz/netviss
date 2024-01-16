#!/bin/bash

# Update system's package index
sudo apt-get update

# Install PostgreSQL and its dependencies
sudo apt-get install -y postgresql postgresql-contrib

# Optional: Secure the installation (set password for the PostgreSQL user, etc.)
# sudo passwd postgres
