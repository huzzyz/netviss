#!/bin/bash

# Function to update FreeRADIUS SQL configuration
update_freeradius_config() {
    local db_user=$1
    local db_pass=$2
    local db_name=$3
    local db_server=$4
    local db_port=$5

    # Path to the FreeRADIUS SQL configuration file
    local sql_config_file="/etc/freeradius/3.0/mods-available/sql"

    # Update the configuration file
    sed -i "s/server = .*/server = \"$db_server\"/" $sql_config_file
    sed -i "s/port = .*/port = $db_port/" $sql_config_file
    sed -i "s/login = .*/login = \"$db_user\"/" $sql_config_file
    sed -i "s/password = .*/password = \"$db_pass\"/" $sql_config_file
    sed -i "s/radius_db = .*/radius_db = \"$db_name\"/" $sql_config_file

    echo "FreeRADIUS SQL configuration updated."
}

# Function to restart FreeRADIUS and check status
restart_freeradius() {
    systemctl restart freeradius
    if [[ $? -eq 0 ]]; then
        echo "FreeRADIUS service restarted successfully."
    else
        echo "Failed to restart FreeRADIUS service. Check for errors."
    fi
}

# Main script starts here
echo "FreeRADIUS Configuration Script"

# Gather database details from user
read -p "Enter PostgreSQL database username: " db_user
read -sp "Enter PostgreSQL database password: " db_pass
echo ""
read -p "Enter PostgreSQL database name: " db_name
read -p "Enter PostgreSQL server address [localhost]: " db_server
db_server=${db_server:-localhost} # Default value if left blank
read -p "Enter PostgreSQL server port [5432]: " db_port
db_port=${db_port:-5432} # Default value if left blank

# Update FreeRADIUS configuration
update_freeradius_config $db_user $db_pass $db_name $db_server $db_port

# Restart FreeRADIUS service
restart_freeradius
