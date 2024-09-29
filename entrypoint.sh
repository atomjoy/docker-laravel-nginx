#!/bin/bash

if [ ! f "vendor/autoload.php" ]; then
    composer install --no-progress --no-interactions
fi

if [ ! f ".env" ]; then
    echo "Creating .env file"
    cp .env.example .env
fi

# Daemonize php-fpm
php-fpm -D

# Enable nginx foreground
nginx -g "daemon off;"