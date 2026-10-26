FROM php:8.3-apache

COPY apache-democis.conf /etc/apache2/conf-enabled/zz-democis.conf
COPY php-democis.ini /usr/local/etc/php/conf.d/democis.ini
COPY site/ /var/www/html/
