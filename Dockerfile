FROM dunglas/frankenphp:1.12.1-php8.4.19-trixie

RUN \
    apt-get -y update && \
    apt-get install -y --no-install-recommends procps && \
    IPE_GD_WITHOUTAVIF=1 install-php-extensions \
        @composer \
        pcntl \
        pdo_mysql \
        gd \
        intl \
        zip \
        ctype \
        opcache \
        redis \
        yaml \
        exif \
        imagick \
        bcmath && \
    apt-get -y autoremove && \
    apt-get clean
