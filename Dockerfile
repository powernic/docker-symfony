FROM php:8.0.8-fpm-alpine3.14

RUN apk add --no-cache \
	bash \
	icu-dev \
	libzip-dev \
	libxml2-dev \
	git
	
RUN curl -s https://get.symfony.com/cli/installer | bash \
	&& mv /root/.symfony/bin/symfony /usr/local/bin/symfony

RUN docker-php-ext-install opcache intl mysqli pdo_mysql zip xml &&\
	docker-php-ext-enable opcache intl mysqli pdo_mysql zip xml
	
RUN echo "short_open_tag = Off" > /usr/local/etc/php/php.ini

RUN php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');" \
	&& php -r "if (hash_file('sha384', 'composer-setup.php') === '756890a4488ce9024fc62c56153228907f1545c228516cbf63f885e036d37e9a59d27d63f46af1d4d07ee0f76181c7d3') { echo 'Installer verified'; } else { echo 'Installer corrupt'; unlink('composer-setup.php'); } echo PHP_EOL;" \
	&& php composer-setup.php \
	&& php -r "unlink('composer-setup.php');" \
	&& mv composer.phar /usr/local/bin/composer
	
RUN apk add --no-cache \
    autoconf \
	automake \
	libtool \
	m4 \
    gcc \
    libc-dev \
    make \
	&& pecl install xdebug && docker-php-ext-enable xdebug 
	
RUN apk add --no-cache \
	postgresql-dev \
	&& docker-php-ext-install pdo_pgsql \
	&& docker-php-ext-enable pdo_pgsql
	
RUN pecl install apcu \
	&& docker-php-ext-enable apcu \
	&& echo "apc.enable_cli=1" >> /usr/local/etc/php/php.ini \
	&& echo "apc.enable=1" >> /usr/local/etc/php/php.ini

RUN apk add --no-cache \
		freetype-dev \
        libjpeg-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
		libxml2-dev \
		libwebp-dev \
		procps &&\
		docker-php-ext-configure gd \
		  --with-freetype \
		  --with-webp \
		  --with-jpeg \
		&& docker-php-ext-install gd \
	&& docker-php-ext-enable pdo_pgsql