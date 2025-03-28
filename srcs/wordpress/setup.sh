#!/bin/bash

if [ ! -f /var/www/html/wp-config.php ]; then
    wp core download --allow-root
fi


cp wp-config-sample.php wp-config.php

sed -i -r "s/database_name_here/$DATABASE_NAME/" wp-config.php
sed -i -r "s/username_here/$DATABASE_USER/" wp-config.php
sed -i -r "s/password_here/$DATABASE_PASSWORD/" wp-config.php
sed -i -r "s/localhost/mariadb/" wp-config.php

sed -i 's|listen = /run/php/php7.3-fpm.sock|listen = 9000|g' /etc/php/7.3/fpm/pool.d/www.conf

sleep 10

wp core install --url=$DOMAIN_NAME --title=$WORDPRESS_TITLE --admin_user=$WORDPRESS_USER_ADMIN --admin_password=$WORDPRESS_PASSWORD_ADMIN --admin_email=$WORDPRESS_EMAIL_ADMIN --allow-root

wp user create $WORDPRESS_USER $WORDPRESS_EMAIL_USER --user_pass=$WORDPRESS_PASSWORD_USER --role=author --allow-root


wp option update home "https://mmansuri.42.fr" --allow-root
wp option update siteurl "https://mmansuri.42.fr" --allow-root

chmod -R 755 wp-content/uploads
chown -R www-data:www-data wp-content/uploads

php-fpm7.3 -F