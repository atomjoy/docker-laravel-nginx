# Nginx and Php-fpm with Laravel on Docker

Running php-fpm and nginx processes in the same container with Laravel (mysql, mariadb, sqlite).

## Config Mysql in files

```sh
.env
webapp/.env
```

## Build

```sh
# Build up
docker compose up --build -d

# Show
docker compose ps

# Interactive container terminal
docker exec -it app_host bash
docker exec -it mysql_host bash
```
