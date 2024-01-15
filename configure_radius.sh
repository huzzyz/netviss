#!/bin/bash

# Function to check if running with sudo
check_root() {
    if [ "$(id -u)" != "0" ]; then
        echo "This script must be run as root. Use sudo."
        exit 1
    fi
}

# Function to check and install jq if not present
check_jq_installed() {
    if ! command -v jq &> /dev/null; then
        echo "jq is not installed. Installing jq..."
        apt-get update
        apt-get install -y jq
    fi
}

# Function to search for FreeRADIUS configuration files
search_config_files() {
    clients_conf=$(find /etc/freeradius -name 'clients.conf' | head -n 1)
    eap_conf=$(find /etc/freeradius -name 'eap' | grep 'mods-available' | head -n 1)

    if [ -z "$clients_conf" ] || [ -z "$eap_conf" ]; then
        echo "Unable to locate FreeRADIUS configuration files."
        exit 1
    fi
}

# Function to prompt for JSON file location
prompt_for_json_file() {
    read -p "Enter the path to your configuration JSON file or press Enter to use the default (./config.json): " json_file
    json_file="${json_file:-./config.json}"

    if [ ! -f "$json_file" ]; then
        echo "Configuration file not found at $json_file."
        exit 1
    fi
}

# Read JSON using jq
read_json() {
    jq -r "$1" "$json_file"
}

# Function to apply client configurations
apply_client_configurations() {
    total_clients=$(read_json '.clients | length')
    for (( i=0; i<"$total_clients"; i++ ))
    do
        name=$(read_json ".clients[$i].name")
        ip=$(read_json ".clients[$i].ip")
        sharedKey=$(read_json ".clients[$i].sharedKey")

        # Add client to clients.conf
        echo "client \"$name\" {" >> "$clients_conf"
        echo "    ipaddr = $ip" >> "$clients_conf"
        echo "    secret = $sharedKey" >> "$clients_conf"
        echo "}" >> "$clients_conf"
    done
}

# Function to configure FreeRADIUS with existing PostgreSQL database
configure_radius_with_existing_postgres() {
    echo "Configuring FreeRADIUS to use existing PostgreSQL database..."

    # Configuration file paths
    local sql_module_config="/etc/freeradius/3.0/mods-available/sql"
    local sql_config_postgres="/etc/freeradius/3.0/mods-config/sql/main/postgresql/sql.conf"

    # Database connection details - replace these with your actual database details
    local dbname="your_database_name"
    local dbuser="your_database_username"
    local dbpass="your_database_password"
    local dbhost="your_database_host"  # e.g., "localhost"
    local dbport="your_database_port"  # e.g., "5432"

    # Backup existing configuration files
    cp "$sql_module_config" "${sql_module_config}.backup"
    cp "$sql_config_postgres" "${sql_config_postgres}.backup"

    # Enable SQL module in FreeRADIUS
    ln -sf "$sql_module_config" /etc/freeradius/3.0/mods-enabled/

    # Modify the SQL module to use PostgreSQL
    sed -i 's/dialect = "sqlite"/dialect = "postgresql"/' "$sql_module_config"
    sed -i 's/#\s*read_clients = yes/read_clients = yes/' "$sql_module_config"

    # Configure PostgreSQL connection settings
    sed -i "s/server = .*/server = \"$dbhost\"/" "$sql_config_postgres"
    sed -i "s/port = .*/port = $dbport/" "$sql_config_postgres"
    sed -i "s/login = .*/login = \"$dbuser\"/" "$sql_config_postgres"
    sed -i "s/password = .*/password = \"$dbpass\"/" "$sql_config_postgres"
    sed -i "s/radius_db = .*/radius_db = \"$dbname\"/" "$sql_config_postgres"

    echo "FreeRADIUS is now configured to use the existing PostgreSQL database."
}

# Function to test FreeRADIUS configuration
test_freeradius_config() {
    systemctl restart freeradius.service
    if systemctl is-active --quiet freeradius.service; then
        echo "FreeRADIUS configuration test passed."
    else
        echo "FreeRADIUS configuration test failed."
        return 1
    fi
}

# Main script execution
check_root
check_jq_installed
search_config_files
prompt_for_json_file

# Backup existing configuration
cp "$clients_conf" "${clients_conf}.backup"
cp "$eap_conf" "${eap_conf}.backup"

apply_client_configurations
configure_radius_with_existing_postgres

# Test FreeRADIUS configuration
if ! test_freeradius_config; then
    echo "Restoring backup due to failed configuration."
    cp "${clients_conf}.backup" "$clients_conf"
    cp "${eap_conf}.backup" "$eap_conf"
    exit 1
else
    echo "FreeRADIUS configuration updated successfully."
fi
