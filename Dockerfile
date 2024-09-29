# Webserver
FROM php:8.2-fpm-bookworm AS php

# Mysql init
COPY ./mysql/init.sql /docker-entrypoint-initdb.d/init.sql

# Env
ENV PHP_OPCACHE_ENABLE=1
ENV PHP_OPCACHE_ENABLE_CLI=0
ENV PHP_OPCACHE_VALIDATE_TIMESTAMP=1
ENV PHP_OPCACHE_REVALIDATE_FREQ=1

# RUN usermod -u 1000 www-data

# Apt https
RUN apt-get update -y
RUN apt-get install apt-transport-https -y

# Libs
RUN apt-get install -y unzip zip nano libpq-dev libcurl4-gnutls-dev nginx
RUN apt-get install -y libicu-dev libmariadb-dev zlib1g-dev libwebp-dev libxpm-dev libjpeg-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev

# Extensions php
RUN docker-php-ext-install pdo pdo_mysql bcmath curl opcache intl gettext gd
RUN docker-php-ext-configure gd --enable-gd --with-webp --with-xpm --with-jpeg --with-freetype 
RUN docker-php-ext-install -j$(nproc) gd

# Redis
RUN pecl install redis-5.3.7 \
	&& pecl install xdebug-3.2.1 \
	&& docker-php-ext-enable redis xdebug

# Memcached
RUN apt-get update && apt-get install -y libmemcached-dev libssl-dev zlib1g-dev \
	&& pecl install memcached-3.2.0 \
	&& docker-php-ext-enable memcached

# Disable default server
RUN rm -rf /etc/nginx/sites-enabled/default

WORKDIR /var/www/html

COPY --chown=www-data:www-data --chmod=2775 ./webapp /var/www/html

COPY ./nginx/default.conf /etc/nginx/conf.d/default.conf

COPY ./php/www.conf /usr/local/etc/php-fpm.d/www.conf

COPY ./php/php.ini /usr/local/etc/php/php.ini

# Remove for app:9000 in nginx default.conf
RUN nginx -t

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

RUN php artisan cache:clear
RUN php artisan config:clear
RUN php artisan migrate
RUN php artisan storage:link

COPY --chown=www-data:www-data --chmod=2775 ./entrypoint.sh /var/www/entrypoint.sh

RUN chmod +x /var/www/entrypoint.sh

ENTRYPOINT [ "/var/www/entrypoint.sh" ]
