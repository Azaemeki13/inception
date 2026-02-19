#!/bin/sh

# Wait for MariaDB to be fully initialized and reachable via the network
# This prevents the WordPress setup from failing due to a missing database
sleep 10

# Move to the web root directory
cd /var/www/html

# Check if WordPress is already installed to allow for data persistence
if [ ! -f "wp-config.php" ]; then

    # 1. Download WordPress core files
    wp core download --allow-root

    # 2. Create wp-config.php using environment variables
    # Connects to the 'mariadb' service defined in docker-compose.yml
    wp config create --allow-root \
        --dbname=$SQL_DATABASE \
        --dbuser=$SQL_USER \
        --dbpass=$SQL_PASSWORD \
        --dbhost=mariadb:3306

    # 3. Perform the core installation
    # Note: Ensure $WP_ADMIN_USER does not contain forbidden strings
    wp core install --allow-root \
        --url=$DOMAIN_NAME \
        --title=$WP_TITLE \
        --admin_user=$WP_ADMIN_USER \
        --admin_password=$WP_ADMIN_PASSWORD \
        --admin_email=$WP_ADMIN_EMAIL

    # 4. Create the second mandatory user
    wp user create --allow-root \
        $WP_USER $WP_USER_EMAIL \
        --user_pass=$WP_USER_PASSWORD \
        --role=author

fi

# Start php-fpm in the foreground as PID 1
# Using 'exec' ensures the script is replaced by the PHP process, avoiding hacky loops
exec php-fpm8.2 -F
