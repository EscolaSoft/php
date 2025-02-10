FROM php:8.4.3-zts-bookworm
RUN apt-get update && apt-get upgrade -y && apt-get install -y \
    git curl libzip-dev unzip \
    --no-install-recommends && \
    apt-get autoremove -y && \
    rm -rf /var/lib/apt/lists/* && \
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
    
RUN apt-get update && apt-get upgrade -y && apt-get remove curl -y &&  apt-get autoremove -y && rm -rf /var/lib/apt/lists/*
