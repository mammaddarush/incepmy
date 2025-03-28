#!/bin/bash

# =============================================
# MariaDB/MySQL Database Initialization Script

# Database directory path
DB_DIR="/var/lib/mysql"

# --------------------------------------------------
# Database Directory Initialization

if [ ! -d "$DB_DIR/mysql" ]; then
    echo "Initializing MariaDB data directory..."
    mariadb-install-db --user=mysql --basedir=/usr --datadir="$DB_DIR"
fi

# --------------------------------------------------
# Network Configuration

sed -i "s|bind-address\s*=\s*127.0.0.1|bind-address = 0.0.0.0|g" /etc/mysql/mariadb.conf.d/50-server.cnf

# --------------------------------------------------
# Database Server Startup

echo "Starting MariaDB..."
mysqld_safe --datadir="$DB_DIR" &

# --------------------------------------------------
# Database Availability Check

wait_for_mysql() {
    until mysqladmin ping --silent; do
        echo "Waiting for MySQL to be up..."
        sleep 10
    done
}
wait_for_mysql

echo "Configuring MariaDB..."

# --------------------------------------------------
# Database Configuration

mysql -u root <<-EOF

    CREATE DATABASE IF NOT EXISTS \`${DATABASE_NAME}\`;
    

    CREATE USER IF NOT EXISTS '${DATABASE_USER}'@'%' IDENTIFIED BY '${DATABASE_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${DATABASE_NAME}\`.* TO '${DATABASE_USER}'@'%';
    

    CREATE USER IF NOT EXISTS '${WORDPRESS_USER_ADMIN}'@'%' IDENTIFIED BY '${WORDPRESS_PASSWORD_ADMIN}';
    GRANT ALL PRIVILEGES ON \`${DATABASE_NAME}\`.* TO '${WORDPRESS_USER_ADMIN}'@'%';
    GRANT ALL PRIVILEGES ON *.* TO '${WORDPRESS_USER_ADMIN}'@'%' WITH GRANT OPTION;
    

    ALTER USER 'root'@'localhost' IDENTIFIED BY '${DATABASE_ROOT_PASSWORD}';
    

    FLUSH PRIVILEGES;
EOF

# Keep the container running after configuration
wait