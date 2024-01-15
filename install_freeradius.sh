#!/bin/bash

# Ensure the script is run as root
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: This script must be run as root."
    exit 1
fi

echo "----------------------------------------"
echo " FreeRADIUS and PostgreSQL Setup Script "
echo "----------------------------------------"

# Function to update package lists
update_packages() {
    echo "Step 1: Updating package lists..."
    apt-get update
    echo "Package lists updated successfully."
}

# Function to install FreeRADIUS and PostgreSQL
install_freeradius() {
    echo "Step 2: Installing FreeRADIUS and PostgreSQL..."
    apt-get install -y freeradius freeradius-utils freeradius-common freeradius-postgresql postgresql
    systemctl enable freeradius.service
    echo "FreeRADIUS and PostgreSQL installation completed."
}

# Function to generate SSL certificates for EAP
generate_ssl_certificates() {
    echo "Step 3: Generating SSL certificates for EAP..."
    mkdir -p /etc/freeradius/3.0/certs
    openssl genrsa -out /etc/freeradius/3.0/certs/server.key 2048
    openssl req -new -x509 -key /etc/freeradius/3.0/certs/server.key -out /etc/freeradius/3.0/certs/server.pem -days 365 -subj "/CN=$(hostname)/O=YourOrganization/C=US"
    chown freerad:freerad /etc/freeradius/3.0/certs/server.key /etc/freeradius/3.0/certs/server.pem
    chmod 640 /etc/freeradius/3.0/certs/server.key /etc/freeradius/3.0/certs/server.pem
    echo "SSL certificate generation completed."
}

# Function to configure the EAP module
configure_eap() {
    echo "Step 4: Configuring the EAP module..."
    sed -i 's|private_key_file =.*|private_key_file = /etc/freeradius/3.0/certs/server.key|' /etc/freeradius/3.0/mods-available/eap
    sed -i 's|certificate_file =.*|certificate_file = /etc/freeradius/3.0/certs/server.pem|' /etc/freeradius/3.0/mods-available/eap
    ln -s /etc/freeradius/3.0/mods-available/eap /etc/freeradius/3.0/mods-enabled/
    echo "EAP module configuration completed."
}

# Function to enable PostgreSQL module
enable_postgresql_module() {
    echo "Step 5: Enabling PostgreSQL module..."
    ln -s /etc/freeradius/3.0/mods-available/sql /etc/freeradius/3.0/mods-enabled/
    ln -s /etc/freeradius/3.0/mods-available/sql/postgresql /etc/freeradius/3.0/mods-enabled/
    echo "PostgreSQL module enabled. Configuration required after setup."
}

# Restart FreeRADIUS service
restart_freeradius() {
    echo "Step 6: Restarting FreeRADIUS service to apply all configurations..."
    systemctl restart freeradius.service
    echo "FreeRADIUS service restarted successfully."
}

# Start the setup process
update_packages
install_freeradius
generate_ssl_certificates
configure_eap
enable_postgresql_module
restart_freeradius

echo "----------------------------------------"
echo " Installation and Configuration Complete"
echo "----------------------------------------"
echo "Please ensure to configure PostgreSQL for FreeRADIUS as per your requirements."
