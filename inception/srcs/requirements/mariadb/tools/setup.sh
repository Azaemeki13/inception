#!/bin/sh

service mariadb start
until mariadb-admin ping > /dev/null 2>&1; do
    sleep 1
done

mariadb -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"

mariadb -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"

mariadb -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';"

mariadb -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"

mariadb -e "FLUSH PRIVILEGES;"

mysqladmin -u root -p${SQL_ROOT_PASSWORD} shutdown

exec mysqld_safe
