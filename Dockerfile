FROM php:8.2-apache
MAINTAINER Gutar "<admin@escolasoft.com>"
ENV DEBIAN_FRONTEND=noninteractive


RUN apt-get update -y && apt-get install -y \
  curl \
  git-core \
  gzip \
  openssh-client \
  unzip \
  zip \
  gcc \
  g++ \
  make \
  sudo \
  gnupg \
  gnupg2 \
  zlib1g-dev \
  zlib1g \
  libpng-dev \
  libpq-dev \
  libicu-dev \
  libc-client-dev \
  libkrb5-dev \
  odbcinst \
  unixodbc \
  --no-install-recommends && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/*

# Install default PHP Extensions
RUN docker-php-ext-install -j$(nproc) \
  bcmath \
  mysqli \
  pdo \
  pdo_mysql \
  gd \
  pdo_pgsql \
  pgsql \
  intl \
  calendar \
  pcntl \
  exif \
  calendar 

# Install Intl, LDAP, GD, SOAP, Tidy, XSL, Zip PHP Extensions
RUN apt-get update -y && apt-get install -y \
  zlib1g-dev \
  libicu-dev \
  g++ \
  libldap2-dev \
  libgd-dev \
  libzip-dev \
  libtidy-dev \
  libxml2-dev \
  libxslt-dev \
  --no-install-recommends && \
  apt-mark auto \
  zlib1g-dev \
  libicu-dev \
  g++ \
  libldap2-dev \
  libxml2-dev \
  libxslt-dev && \
  docker-php-ext-configure intl && \
  docker-php-ext-configure odbc && \
  docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
  docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
  docker-php-ext-configure gd --with-freetype --with-jpeg && \
  docker-php-ext-install -j$(nproc) \
  intl \
  ldap \
  gd \
  soap \
  tidy \
  xsl \
  imap \
  zip && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
  rm -rf /var/lib/apt/lists/*
  
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash - && \
  apt-get update && \
  apt-get -y install nodejs gcc g++ make && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/*

RUN curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
  apt update && apt -y install yarn && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/*

#REDIS
RUN pecl install redis && docker-php-ext-enable redis

#PCOV
RUN pecl install pcov && docker-php-ext-enable pcov

#Add Composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php && \
  php composer-setup.php --install-dir=/usr/local/bin --filename=composer  && \
  rm *

#PHP
RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini && \
  sed -i 's/128M/4G/g' /usr/local/etc/php/php.ini && \
  sed -i 's/8M/512M/g' /usr/local/etc/php/php.ini && \
  sed -i 's/ 2M/ 512M/g' /usr/local/etc/php/php.ini
   
# Apache 
RUN { \
  echo "<VirtualHost *:80>"; \
  echo "  DocumentRoot /var/www/html/public"; \
  echo "  LogLevel warn"; \
  echo "  ErrorLog /var/log/apache2/error.log"; \
  echo "  CustomLog /var/log/apache2/access.log combined"; \
  echo "  ServerSignature Off"; \
  echo "  <Directory /var/www/html/public>"; \
  echo "    Options +FollowSymLinks"; \
  echo "    Options -ExecCGI -Includes -Indexes"; \
  echo "    AllowOverride all"; \
  echo; \
  echo "    Require all granted"; \
  echo "  </Directory>"; \
  echo "  <LocationMatch assets/>"; \
  echo "    php_flag engine off"; \
  echo "  </LocationMatch>"; \
  echo; \
  echo "  IncludeOptional sites-available/000-default.local*"; \
  echo "</VirtualHost>"; \
  } | tee /etc/apache2/sites-available/000-default.conf

RUN echo "ServerName localhost" > /etc/apache2/conf-available/fqdn.conf && \
  echo "date.timezone = Europe/Warsaw" > /usr/local/etc/php/conf.d/timezone.ini && \
  echo "log_errors = On\nerror_log = /dev/stderr" > /usr/local/etc/php/conf.d/errors.ini && \
  a2enmod rewrite expires remoteip cgid && \
  usermod -u 1000 www-data && \
  usermod -G staff www-data

#APACHE homedir user 
RUN chown -R www-data:www-data /var/www

EXPOSE 80
CMD ["apache2-foreground"]

