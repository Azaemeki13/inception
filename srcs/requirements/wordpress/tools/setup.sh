#!/bin/sh

cd /var/www/html

# Wait for MariaDB to be ready (proper health check instead of sleep)
echo "Waiting for MariaDB..."
while ! mariadb-admin -h mariadb -u "${SQL_USER}" -p"${SQL_PASSWORD}" ping >/dev/null 2>&1; do
    echo "MariaDB not ready yet, retrying..."
    sleep 2
done
echo "MariaDB is reachable."

# Check if WordPress is already installed to allow for data persistence
if [ ! -f "wp-config.php" ]; then

    # 1. Download WordPress core files
    wp core download --allow-root

    # 2. Create wp-config.php using environment variables
    wp config create --allow-root \
        --dbname="$SQL_DATABASE" \
        --dbuser="$SQL_USER" \
        --dbpass="$SQL_PASSWORD" \
        --dbhost=mariadb:3306

    # 3. Perform the core installation
    wp core install --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="$WP_TITLE" \
        --admin_user="$WP_ADMIN_USER" \
        --admin_password="$WP_ADMIN_PASSWORD" \
        --admin_email="$WP_ADMIN_EMAIL"

    # 4. Create the second mandatory user
    wp user create --allow-root \
        "$WP_USER" "$WP_USER_EMAIL" \
        --user_pass="$WP_USER_PASSWORD" \
        --role=author

fi

# Start php-fpm in the foreground as PID 1
exec php-fpm8.2 -F
