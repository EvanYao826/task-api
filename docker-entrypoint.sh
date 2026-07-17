#!/bin/bash

set -e

echo "Waiting for MySQL to be ready..."

until php -r "
try {
    \$pdo = new PDO(
        'mysql:host=' . getenv('DB_HOST') . ';port=' . getenv('DB_PORT'),
        getenv('DB_USERNAME'),
        getenv('DB_PASSWORD'),
        [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
    );
    echo 'MySQL is ready!' . PHP_EOL;
    exit(0);
} catch (PDOException \$e) {
    echo 'MySQL is not ready yet...' . PHP_EOL;
    exit(1);
}
"
do
    sleep 2
done

if [ ! -d "vendor" ] || [ ! -f "vendor/autoload.php" ]; then
    echo "Installing composer dependencies..."
    composer config -g repo.packagist composer https://mirrors.aliyun.com/composer/
    composer config policy.advisories.block false
    composer install --no-dev --optimize-autoloader
else
    echo "Composer dependencies already installed, skipping..."
fi

echo "Setting permissions..."
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

if [ -z "$APP_KEY" ] || [ "$APP_KEY" = "base64:" ]; then
    echo "Generating APP_KEY..."
    php artisan key:generate --force
fi

echo "Running migrations..."
php artisan migrate --force

echo "Starting PHP-FPM..."
exec php-fpm