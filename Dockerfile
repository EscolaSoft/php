FROM php:8.0-apache
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
  supervisor \
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
  pcntl


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
  docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ && \
  docker-php-ext-configure gd --with-freetype --with-jpeg && \
  docker-php-ext-install -j$(nproc) \
  opcache \
  intl \
  ldap \
  gd \
  soap \
  tidy \
  xsl \
  zip && \
  apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false && \
  rm -rf /var/lib/apt/lists/*

RUN pecl install -o -f redis \
&&  rm -rf /tmp/pear \
&&  docker-php-ext-enable redis

#Add Composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php && \
  php composer-setup.php --install-dir=/usr/local/bin --filename=composer  && \
  rm *

RUN cp /usr/local/etc/php/php.ini-production /usr/local/etc/php/php.ini && \
  sed -i 's/ 128M/ 2048M/g' /usr/local/etc/php/php.ini && \
  sed -i 's/ 2M/ 256M/g' /usr/local/etc/php/php.ini

# Apache 
RUN { \
  echo "<VirtualHost *:80>"; \
  echo "  DocumentRoot /var/www/html/public"; \
  echo "  LogLevel warn"; \
  echo "  ErrorLog /var/log/apache2/error.log"; \
  echo "  CustomLog /var/log/apache2/access.log combined"; \
  echo "  RequestHeader set X-Forwarded-Proto https"; \
  echo "  RequestHeader set X-Forwarded-SSL https"; \
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
  a2enmod rewrite expires remoteip cgid headers && \
  usermod -u 1000 www-data && \
  usermod -G staff www-data

EXPOSE 80
CMD ["apache2-foreground"]
