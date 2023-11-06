#!/bin/bash

# Update package repositories
sudo apt-get update

# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install MariaDB
sudo debconf-set-selections <<< 'mariadb-server-10.5 mysql-server/root_password password pwd'
sudo debconf-set-selections <<< 'mariadb-server-10.5 mysql-server/root_password_again password pwd'
sudo apt-get install -y mariadb-server

# Start MariaDB service
sudo systemctl start mysql

# Configure your web application here, e.g., copy application files, create databases, etc.
# Initialize the web application database (if required)
# Replace with your specific database setup commands
# Example:
# mysql -u root -p"your-root-password" -e "CREATE DATABASE webappdb;"

# Install the CloudWatch Agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
sudo dpkg -i -E ./amazon-cloudwatch-agent.deb

# Assuming the CloudWatch Agent configuration file is named `cloudwatch-agent-config.json`
# and is located in the root directory of your project.
sudo cp ./cloudwatch-agent-config.json /opt/aws/amazon-cloudwatch-agent/etc/

# Start the CloudWatch Agent
sudo systemctl enable amazon-cloudwatch-agent
sudo systemctl start amazon-cloudwatch-agent

# Enable MariaDB to start on boot
sudo systemctl enable mysql

# Secure MariaDB installation (set root password and remove anonymous users)
sudo mysql_secure_installation <<EOF

pwd
n
n
y
y
y
y
EOF

# Additional configurations and setup for your web application can be added here.

# Restart MariaDB for changes to take effect
sudo systemctl restart mysql

# Optionally, you can add more configuration steps for your specific web application.

# Clean up (remove unnecessary packages and clear cache)
sudo apt-get autoremove -y
sudo apt-get clean

# End of the script