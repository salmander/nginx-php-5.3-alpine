FROM wodby/php-actions-alpine:v1.0.3
MAINTAINER Wodby <hello@wodby.com>

RUN export NGX_VER="1.9.3" && \
    export NGX_UP_VER="0.9.0" && \
    export NGX_LUA_VER="0.9.16" && \
    export NGX_NDK_VER="0.2.19" && \
    export NGX_NXS_VER="0.54rc3" && \
    export LUAJIT_LIB="/usr/lib/" && \
    export LUAJIT_INC="/usr/include/luajit-2.0/" && \
    export PHP_VER="5.3.29" && \
    export TWIG_VER="1.21.1" && \
    export WCLI_VER="0.1" && \
    export WALTER_VER="1.3.0" && \
    echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories && \
    wget -qO- https://github.com/walter-cd/walter/releases/download/v${WALTER_VER}/walter_${WALTER_VER}_linux_amd64.tar.gz | tar xz -C /tmp/ && \
    mkdir /opt/wodby/bin && \
    cp /tmp/walter_linux_amd64/walter /opt/wodby/bin && \ 
    apk add --update sqlite-dev unixodbc-dev libxml2-dev openssl-dev bzip2-dev curl-dev jpeg-dev libpng-dev libxpm-dev freetype-dev gettext-dev gmp-dev imap-dev krb5-dev icu-dev openldap-dev libmcrypt-dev freetds-dev postgresql-dev enchant-dev aspell-dev readline-dev libedit-dev net-snmp-dev tidyhtml-dev@testing libxslt-dev db-dev gdbm-dev build-base autoconf libtool && \
    mkdir -p /usr/include/freetype2/freetype && \
    #ln -s /usr/include/freetype2/freetype.h /usr/include/freetype2/freetype/freetype.h && \
# https://github.com/htacg/tidy-html5/issues/235
    cp /usr/include/tidybuffio.h /usr/include/buffio.h && \
    wget -qO- http://php.net/get/php-${PHP_VER}.tar.gz/from/this/mirror | tar xz -C /tmp && \
    cd /tmp/php-${PHP_VER} && \
    ./configure --prefix=/usr --sysconfdir=/etc/php --localstatedir=/var --with-config-file-path=/etc/php \
    --with-config-file-scan-dir=/etc/php/conf.d --mandir=/usr/share/man --disable-rpath --disable-debug --disable-static \
    --disable-embed --enable-inline-optimization --enable-fpm --enable-pcntl --enable-mbregex --enable-mbstring \
    --enable-shared --enable-session --enable-sqlite-utf8 --enable-pdo=shared --enable-xml=shared --enable-libxml=shared \
    --enable-bcmath=shared --enable-calendar=shared --enable-exif=shared --enable-ftp=shared --enable-json=shared --enable-pcntl=shared \
    --enable-dba=shared --with-db4=shared --with-gdbm=shared --enable-phar=shared --enable-posix=shared --enable-ctype=shared \
    --enable-shmop=shared --enable-soap=shared --enable-sockets=shared --enable-sysvmsg=shared --enable-sysvsem=shared --enable-xmlreader=shared \
    --enable-sysvshm=shared --enable-zip=shared --enable-wddx=shared --enable-intl=shared --enable-dom=shared --with-bz2=shared \
    --with-curl=shared --with-enchant=shared --with-gd=shared --with-jpeg-dir=shared,/usr --with-png-dir=shared,/usr \
    --with-freetype-dir=shared,/usr --enable-gd-native-ttf --enable-gd-jis-conv --with-xmlrpc=shared --with-iconv=shared \
    --with-gettext=shared --with-zlib=shared --with-openssl=shared --with-kerberos --with-imap=shared --with-kerberos \
    --with-imap-ssl=shared --with-ldap=shared --with-ldap-sasl --with-mcrypt=shared --with-mssql=shared --with-gmp=shared \
    --with-pdo-odbc=shared,unixODBC,/usr --with-unixODBC=shared,/usr --with-mysql=shared,mysqlnd \
    --with-mysql-sock=/var/run/mysqld/mysqld.sock --with-zlib-dir=shared --with-pdo-mysql=shared,mysqlnd \
    --with-mysqli=shared,mysqlnd --with-pdo-dblib=shared --with-pdo-sqlite=shared,/usr --with-sqlite3=shared,/usr \
    --with-sqlite=shared --with-pgsql=shared --with-pspell=shared --with-snmp=shared --with-tidy=shared --with-xsl=shared \
    --with-layout=GNU --with-regex=php --with-icu-dir=/usr --with-pcre-regex --with-mhash --with-readline --with-pear \
    --with-pic --with-libdir=lib --without-db1 --without-db2 --without-db3 --without-qdbm --without-apache && \
    make CC='gcc' CFLAGS='-Os -fomit-frame-pointer -g' LDFLAGS='-Wl,--as-needed' CPPFLAGS='-Os -fomit-frame-pointer' CXXFLAGS='-Os -fomit-frame-pointer -g' && \
    make install && \
    strip /usr/bin/php /usr/sbin/php-fpm /usr/lib/php/20090626/* && \
    ln -sf /usr/sbin/php-fpm /usr/bin/php-fpm && \
    ln -sfn /usr/lib/php/20090626 /usr/lib/php/modules && \
    mkdir -p /etc/php/conf.d && \
    echo 'extension=xml.so' > /etc/php/conf.d/xml.ini && \
    echo 'extension=json.so' > /etc/php/conf.d/json.ini && \
    echo 'extension=phar.so' > /etc/php/conf.d/phar.ini && \
    echo 'extension=openssl.so' > /etc/php/conf.d/openssl.ini && \
    echo 'extension=posix.so' > /etc/php/conf.d/posix.ini && \
    echo 'extension=dom.so' > /etc/php/conf.d/dom.ini && \
    echo 'extension=pcntl.so' > /etc/php/conf.d/pcntl.ini && \
    sed -ie 's/-n//g' `which pecl` && \
    pecl install ZendOpcache && \
    pecl install xdebug-2.2.7 && pecl install uploadprogress && pecl install redis && \
    wget -qO- https://github.com/twigphp/Twig/archive/v${TWIG_VER}.tar.gz | tar xz -C /tmp/ && \
    cd /tmp/Twig-${TWIG_VER}/ext/twig && \
    phpize && ./configure && make && make install && \
    apk del --purge *-dev build-base autoconf libtool && apk add libxml2 readline && \
    cd / && rm -rf /tmp/* /usr/include/php /usr/share/man /usr/lib/php/build /usr/lib/php/20090626/*.a && \
    apk add --update git sed nmap-ncat grep wget curl pwgen openssh rsync msmtp patch patchutils inotify-tools mariadb-client krb5-libs \
      redis nano bash diffutils zlib libxml2 readline freetype libjpeg-turbo libpng curl libltdl libmcrypt \
      libbz2 libssl1.0 libcrypto1.0 gzip && \
    ln -sf /usr/bin/msmtp /usr/sbin/sendmail && \
    curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer && \
    git clone https://github.com/drush-ops/drush.git /usr/local/src/drush && \
    cd /usr/local/src/drush && \
    git checkout 7.1.0 && \
    ln -sf /usr/local/src/drush/drush /usr/bin/drush && \
    composer install && rm -rf ./.git && \
    composer create-project wp-cli/wp-cli /usr/local/src/wp-cli --no-dev && \
    ln -sf /usr/local/src/wp-cli/bin/wp /usr/bin/wp && \
    git config --global user.name "Administrator" && git config --global user.email "admin@wodby.com" && git config --global push.default current && \

    # Configure php.ini
    sed -i "s/^expose_php.*/expose_php = Off/" /etc/php/php.ini && \
    sed -i "s/^;date.timezone.*/date.timezone = UTC/" /etc/php/php.ini && \
    sed -i "s/^memory_limit.*/memory_limit = -1/" /etc/php/php.ini && \
    sed -i "s/^max_execution_time.*/max_execution_time = 300/" /etc/php/php.ini && \
    sed -i "s/^post_max_size.*/post_max_size = 512M/" /etc/php/php.ini && \
    sed -i "s/^upload_max_filesize.*/upload_max_filesize = 512M/" /etc/php/php.ini && \
    echo "extension_dir = \"/usr/lib/php/modules\"" | tee -a /etc/php/php.ini && \
    echo "error_log = \"/var/log/php/error.log\"" | tee -a /etc/php/php.ini && \

    # Configure php log dir
    mkdir /var/log/php && \
    touch /var/log/php/error.log && \
    touch /var/log/php/fpm-error.log && \
    touch /var/log/php/fpm-slow.log && \
    chown -R wodby:wodby /var/log/php && \

    # Clear apk cache
    rm -rf /var/cache/apk/* /tmp/* /usr/bin/su

COPY rootfs /
