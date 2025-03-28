#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m'

sed -i "s/127.0.0.1/0.0.0.0/" /etc/mysql/mariadb.conf.d/50-server.cnf 

# Start the MySQL service
service mysql start

# Wait for MySQL to be fully up and running
until mysqladmin ping &>/dev/null; do
  echo -e "${GREEN}Waiting for MySQL to be up...${NC}"
  sleep 2
done

mysql -u root <<EOF
CREATE DATABASE IF NOT EXISTS ${DATABASE_NAME};
CREATE USER IF NOT EXISTS '${DATABASE_USER}'@'%' IDENTIFIED BY '${DATABASE_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DATABASE_NAME}.* TO '${DATABASE_USER}'@'%';
ALTER USER 'root'@'localhost' IDENTIFIED BY '${DATABASE_ROOT_PASSWORD}';
FLUSH PRIVILEGES;
EOF
# Stop the service to allow the connection from any IP address from the network
kill $(cat /run/mysqld/mysqld.pid)

mysqld_safe