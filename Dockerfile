# Name: Yii2-mssql-ldap
# Version: 1.0.0
# Description: A Yii2 Framework image with Microsoft's SQL drivers and LDAP support

#-------------------------------------------------------------------
# I. BASE IMAGE
#-------------------------------------------------------------------

    # Using Yii2's official docker image as base                                                                        Step 1
FROM yiisoftware/yii2-php:8.1-apache


#-------------------------------------------------------------------
# II. INSTALL TOOLS
#-------------------------------------------------------------------

    # Get updates and install helping tools needed for setup                                                            Step 2
RUN apt-get update && apt-get install --no-install-recommends -y \
        apt-transport-https \
        gettext \
        git \
        unzip \
        vim \
        tree \
        wget

    # Install xdebug 2.9.2                                                                                              Step 3
#RUN pecl install xdebug

    # Set Yii2 image's environment variable                                                                             Step 4
ENV PHP_ENABLE_XDEBUG 1

# Configure LDAP.
RUN apt-get update \
 && apt-get install gnupg libldap2-dev -y \
 && docker-php-ext-configure ldap --with-libdir=lib/x86_64-linux-gnu/ \
 && docker-php-ext-install ldap


#-------------------------------------------------------------------
# III. SET UP DATABASE DRIVERS
#-------------------------------------------------------------------

    # Install multiarch support
RUN curl -O http://ftp.de.debian.org/debian/pool/main/g/glibc/multiarch-support_2.28-10+deb10u1_amd64.deb \
    && dpkg -i multiarch-support_2.28-10+deb10u1_amd64.deb

    # install ODBC:                                                                                                     Step 5
RUN curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get install -y locales \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && apt-get update

    # accept EULA terms and install mssql tools                                                                         Step 6
RUN ACCEPT_EULA=Y apt-get install -y msodbcsql17 unixodbc-dev mssql-tools

    # install PHP PDO SQLSRV driver:                                                                                    Step 7
RUN pecl install sqlsrv \
    && pecl install pdo_sqlsrv \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv


#-------------------------------------------------------------------
# III. SETUP SERVER SETTINGS FOR DEVELOPMENT
#-------------------------------------------------------------------

    # enable Apache rewrite module                                                                                      Step 8
RUN a2enmod rewrite

    # copy new configuration settings                                                                                   Step 9 & 10
COPY image-files/php.ini /usr/local/etc/php/
COPY image-files/xdebug.ini /usr/local/etc/php/conf.d/

    # Update the PHP.ini file to enable short tags since php.ini settings are overwritten in Debian distributions       Step 11
RUN sed -i "s/short_open_tag=0/short_open_tag=1/" 	/usr/local/etc/php/conf.d/base.ini

###<!-- BASE PHP END -->###
