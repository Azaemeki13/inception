#!/bin/sh

# 1. Socket setup
mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld

# 2. Start MariaDB temporarily in background for init
mysqld --user=mysql --datadir=/var/lib/mysql --socket=/run/mysqld/mysqld.sock &

# 3. Wait for MariaDB to be ready
echo "Waiting for MariaDB to start..."
while ! mariadb-admin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
    sleep 1
done
echo "MariaDB is up."

# 4. Initialization Logic (First Boot Only)
if [ ! -d "/var/lib/mysql/${SQL_DATABASE}" ]; then
    echo "First run detected: Provisioning database..."

    mariadb --socket=/run/mysqld/mysqld.sock -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"
    mariadb --socket=/run/mysqld/mysqld.sock -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"
    mariadb --socket=/run/mysqld/mysqld.sock -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';"
    mariadb --socket=/run/mysqld/mysqld.sock -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"
    mariadb --socket=/run/mysqld/mysqld.sock -e "FLUSH PRIVILEGES;"
else
    echo "Database already initialized. Skipping SQL setup."
fi

# 5. Clean shutdown of temporary instance
echo "Shutting down temporary MariaDB instance..."
mariadb-admin -u root -p"${SQL_ROOT_PASSWORD}" --socket=/run/mysqld/mysqld.sock shutdown 2>/dev/null || \
    mariadb-admin --socket=/run/mysqld/mysqld.sock shutdown 2>/dev/null

# Wait for it to fully stop
while mariadb-admin --socket=/run/mysqld/mysqld.sock ping >/dev/null 2>&1; do
    sleep 1
done

# 6. Start MariaDB in foreground as PID 1
echo "MariaDB is ready. Starting in foreground mode."
exec mysqld --user=mysql --bind-address=0.0.0.0
