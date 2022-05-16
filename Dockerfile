FROM php:8.1-fpm

RUN apt-get update -y \
    && apt-get install -y nginx \
    libicu-dev \
    libc-client-dev \
    libkrb5-dev \
    libpng-dev \
    libjpeg-dev \
    zlib1g-dev \
    libzip-dev \
    libxml2-dev \
    zip \
    unzip && \
    apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
    rm -rf /var/lib/apt/lists/*


# PHP_CPPFLAGS are used by the docker-php-ext-* scripts
ENV PHP_CPPFLAGS="$PHP_CPPFLAGS -std=c++11"

RUN docker-php-ext-install pdo_mysql \
    && docker-php-ext-configure intl \
    && docker-php-ext-install intl \
    && docker-php-ext-configure gd --with-jpeg && docker-php-ext-install gd \
    && docker-php-ext-install bcmath \
    && apt-get remove libicu-dev icu-devtools -y

RUN curl -sS https://getcomposer.org/installer -o composer-setup.php && \
  php composer-setup.php --install-dir=/usr/local/bin --filename=composer  && \
  rm *
  
COPY nginx-site.conf /etc/nginx/sites-enabled/default
COPY entrypoint.sh /etc/entrypoint.sh
RUN usermod -u 1000 www-data && usermod -G staff www-data

WORKDIR /var/www/html

EXPOSE 80 443

ENTRYPOINT ["/etc/entrypoint.sh"]