#!/bin/bash
if [ "$SKIP_PIWIK_TEST_PREPARE" == "1" ]; then
    echo "Skipping webserver setup."
    exit 0;
fi

set -e

DIR=$(realpath $(dirname "$0"))

service nginx stop

# Setup PHP-FPM
echo "Configuring php-fpm"

if [[ "$TRAVIS_PHP_VERSION" == 5.3* ]];
then
    # path does not exist with 5.3.3 so use 5.3 
    PHP_FPM_BIN="$HOME/.phpenv/versions/5.3/sbin/php-fpm"
else
    PHP_FPM_BIN="$HOME/.phpenv/versions/$TRAVIS_PHP_VERSION/sbin/php-fpm"
fi;

PHP_FPM_CONF="$DIR/php-fpm.conf"
PHP_FPM_SOCK=$(realpath "$DIR")/php-fpm.sock

if [ -d "$TRAVIS_BUILD_DIR/../piwik/tmp/" ]; then
    PHP_FPM_LOG="$TRAVIS_BUILD_DIR/../piwik/tmp/php-fpm.log"
elif [ -d "$TRAVIS_BUILD_DIR/piwik/tmp/" ]; then
    PHP_FPM_LOG="$TRAVIS_BUILD_DIR/piwik/tmp/php-fpm.log"
elif [ -d "$TRAVIS_BUILD_DIR" ]; then
    PHP_FPM_LOG="$TRAVIS_BUILD_DIR/php-fpm.log"
else
    PHP_FPM_LOG="$HOME/php-fpm.log"
fi

USER=$(whoami)

echo "php-fpm user = $USER"

touch "$PHP_FPM_LOG"

# Adjust php-fpm.ini
sed -i "s/@USER@/$USER/g" "$DIR/php-fpm.ini"
sed -i "s|@PHP_FPM_SOCK@|$PHP_FPM_SOCK|g" "$DIR/php-fpm.ini"
sed -i "s|@PHP_FPM_LOG@|$PHP_FPM_LOG|g" "$DIR/php-fpm.ini"
sed -i "s|@PATH@|$PATH|g" "$DIR/php-fpm.ini"

# Start daemons
echo "Starting php-fpm"
#$PHP_FPM_BIN --fpm-config "$DIR/php-fpm.ini"

echo "Starting webserver"
php -S localhost:8000 >/dev/null 2>webserver.log &
