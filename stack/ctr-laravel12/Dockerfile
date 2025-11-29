FROM debian:trixie-slim

LABEL maintainer="infra@bskp.local"

ARG DEBIAN_FRONTEND=noninteractive
ENV COMPOSER_ALLOW_SUPERUSER=1 \
    COMPOSER_HOME=/tmp/composer \
    PATH="/var/www/html/vendor/bin:${PATH}" \
    WORKDIR=/var/www/html

# Base packages + PHP repository
RUN set -eux; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        git \
        gnupg \
        lsb-release \
        unzip \
        zip \
        libpng-dev \
        libonig-dev \
        libxml2-dev \
        libzip-dev \
        pkg-config; \
    mkdir -p /etc/apt/keyrings; \
    curl -fsSL https://packages.sury.org/php/apt.gpg | gpg --dearmor -o /etc/apt/keyrings/sury-php.gpg; \
    echo "deb [signed-by=/etc/apt/keyrings/sury-php.gpg] https://packages.sury.org/php/ $(lsb_release -cs) main" > /etc/apt/sources.list.d/sury-php.list; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        default-mysql-server \
        default-mysql-client \
        nodejs \
        npm \
        php8.4 \
        php8.4-cli \
        php8.4-fpm \
        php8.4-bcmath \
        php8.4-curl \
        php8.4-gd \
        php8.4-intl \
        php8.4-mbstring \
        php8.4-mysql \
        php8.4-pgsql \
        php8.4-readline \
        php8.4-sqlite3 \
        php8.4-xml \
        php8.4-zip \
        tini; \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer; \
    mkdir -p /var/www/html; \
    sed -i 's/^bind-address.*/bind-address = 0.0.0.0/' /etc/mysql/mariadb.conf.d/50-server.cnf; \
    apt-get clean; \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

WORKDIR /var/www/html

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8000 3306

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/entrypoint.sh"]
CMD []
