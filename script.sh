#!/bin/bash

# Update and upgrade the system
sudo apt update && sudo apt -y upgrade

# Install Node.js and npm from the nodesource repository for the latest version
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

# The 'npm' package isn't required as the latest Node.js comes with npm. If it doesn't, remove the comment from the line below.
# sudo apt-get install -y npm

# Install sequelize globally (if needed in your case)
npm install -g sequelize

# Install MariaDB server and client
sudo apt-get install -y mariadb-server mariadb-client

# Start and enable MariaDB
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Check if MariaDB is running
if ! sudo systemctl is-active --quiet mariadb; then
    echo "MariaDB is not running. Exiting."
    exit 1
fi

# Create a database if it doesn't exist
DB_NAME="projectDatabase"  # Updated to the new database name

if sudo mysql -u root -e "USE $DB_NAME" 2>/dev/null; then
    echo "Database $DB_NAME already exists."
else
    echo "Creating database $DB_NAME..."
    sudo mysql -u root -proot <<SQL
CREATE DATABASE $DB_NAME;
GRANT ALL PRIVILEGES ON $DB_NAME.* TO 'root'@'localhost' IDENTIFIED BY 'root';
FLUSH PRIVILEGES;
SHOW DATABASES;
SQL
    echo "Database $DB_NAME created."
fi

# Secure MariaDB installation (set root password and remove anonymous users)
# Since your password is already 'root', we'll make sure it remains unchanged during the secure installation.
sudo mysql_secure_installation <<EOF

n
root
root
y
y
y
y
EOF

# Ensure /opt/webapp directory exists and has the right permissions
sudo mkdir -p /opt/webapp
sudo chown -R $(whoami) /opt/webapp

# Change to webapp directory and install sequelize and mysql using npm
cd /opt/webapp || exit
npm install sequelize mysql

# Add Node.js app to startup using systemd
echo "[Unit]
Description=Node.js WebApp
After=network.target

[Service]
ExecStart=/usr/bin/node /opt/webapp/index.js
WorkingDirectory=/opt/webapp
StandardOutput=syslog
StandardError=syslog
Restart=always
User=nobody

[Install]
WantedBy=multi-user.target" | sudo tee /etc/systemd/system/webapp.service

# Reload systemd to recognize new service
sudo systemctl daemon-reload

# Enable and start the new service
sudo systemctl enable webapp.service
sudo systemctl start webapp.service

# Clean up (remove unnecessary packages and clear cache)
sudo apt-get autoremove -y
sudo apt-get clean

# End of the script
