FROM php:8.4.3-zts-bullseye
RUN apt-get update && apt-get install -y \
    git curl libzip-dev unzip && \
    docker-php-ext-install zip && \
    # Install install-php-extensions
    curl -sSL https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions \
    -o /usr/local/bin/install-php-extensions && \
    chmod +x /usr/local/bin/install-php-extensions
RUN install-php-extensions \
    @composer \
    pcntl \
    pdo_mysql \
    gd \
    intl \
    zip \
    ctype \
    opcache \
    redis

