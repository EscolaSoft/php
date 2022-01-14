FROM php:5.6-apache

# Install developer dependencies
RUN apt-get update -yqq && apt-get dist-upgrade -yqq && apt-get install -y git curl libaio1 unzip libaio1 libxslt-dev libsqlite3-dev libsqlite3-0 libxml2-dev libicu-dev libfreetype6-dev libmcrypt-dev git libcurl4-gnutls-dev libbz2-dev libssl-dev libpq-dev libfreetype6-dev libjpeg62-turbo-dev libmagickwand-dev mcrypt -yqq && \
  apt-get autoremove -y && \
  rm -rf /var/lib/apt/lists/*

# Install php extensions
RUN docker-php-ext-install mysqli mysql pdo_mysql pdo
RUN docker-php-ext-install opcache
RUN docker-php-ext-install json
RUN docker-php-ext-install calendar
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install xml
RUN docker-php-ext-install zip
RUN docker-php-ext-install xsl
RUN docker-php-ext-install bz2
RUN docker-php-ext-install mbstring
RUN docker-php-ext-install mcrypt
RUN docker-php-ext-install curl
RUN docker-php-ext-install xsl

# Install PECL extensions
#RUN docker-php-ext-install phar
RUN docker-php-ext-install intl
RUN pecl install imagick
RUN docker-php-ext-enable imagick

RUN a2enmod  rewrite \
    && a2enmod deflate \
    && a2enmod headers \
    && a2ensite 000-default.conf

#Add Composer
RUN curl -sS https://getcomposer.org/installer -o composer-setup.php && \
    php composer-setup.php --install-dir=/usr/local/bin --filename=composer --version=1.10.17 && \
    rm *


RUN echo "log_errors = On" >> /usr/local/etc/php/php.ini
RUN echo "display_errors = On" >> /usr/local/etc/php/php.ini
RUN echo "display_startup_errors = On" >> /usr/local/etc/php/php.ini
RUN echo "error_reporting = E_ALL" >> /usr/local/etc/php/php.ini
RUN echo "error_log = /dev/stdout" >> /usr/local/etc/php/php.ini
RUN echo 'post_max_size = 200M' >> 	/usr/local/etc/php/php.ini
RUN echo 'upload_max_filesize =  200M' >> 	/usr/local/etc/php/php.ini
RUN echo 'date.timezone = "Europe/Warsaw"' >> 	/usr/local/etc/php/php.ini

RUN { \
  echo "<VirtualHost *:80>"; \
  echo "  DocumentRoot /var/www/html/web"; \
  echo "  LogLevel warn"; \
  echo "  ErrorLog /var/log/apache2/error.log"; \
  echo "  CustomLog /var/log/apache2/access.log combined"; \
  echo "  ServerSignature Off"; \
  echo "  <Directory /var/www/html>"; \
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

RUN usermod -u 1000 www-data && \
  usermod -G staff www-data

ENV TERM=xterm \
TZ=Europe/Warsaw

CMD ["/usr/sbin/apache2ctl", "-D", "FOREGROUND"]
