#!/bin/bash

# Function to update the FreeRADIUS SQL configuration
update_freeradius_config() {
    local db_user=$1
    local db_pass=$2
    local db_name=$3

    # Path to the FreeRADIUS SQL configuration file
    local sql_config_file="/etc/freeradius/3.0/mods-available/sql"

    # Update the configuration file
    sed -i "s/.*server = .*/        server = \"localhost\"/" $sql_config_file
    sed -i "s/.*login = .*/        login = \"$db_user\"/" $sql_config_file
    sed -i "s/.*password = .*/        password = \"$db_pass\"/" $sql_config_file
    sed -i "s/.*radius_db = .*/        radius_db = \"$db_name\"/" $sql_config_file

    # Enable the SQL module
    ln -sf /etc/freeradius/3.0/mods-available/sql /etc/freeradius/3.0/mods-enabled/
}

# Main script starts here

echo "FreeRADIUS Configuration Script"

# Prompt for database details
read -p "Enter PostgreSQL database username: " db_user
read -sp "Enter PostgreSQL database password: " db_pass
echo ""
read -p "Enter PostgreSQL database name: " db_name

# Update FreeRADIUS configuration
update_freeradius_config $db_user $db_pass $db_name

# Restart FreeRADIUS service
systemctl restart freeradius

echo "FreeRADIUS has been configured and restarted."
