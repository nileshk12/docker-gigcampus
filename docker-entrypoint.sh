#!/bin/sh
set -e

echo "Starting entrypoint script..."

# Display current user and group information
echo "Current user:"
id

# Ensure correct permissions for storage and cache directories
echo "Setting correct permissions..."
chmod -R 775 /var/www/storage /var/www/bootstrap/cache

# Attempt to create a test file
echo "Attempting to create a test file..."
if touch /var/www/storage/logs/test_file.txt; then
    echo "Test file created successfully."
    rm /var/www/storage/logs/test_file.txt
else
    echo "Failed to create test file. Check permissions."
fi

# Ensure Laravel log file exists and is writable
echo "Ensuring Laravel log file exists and is writable..."
if touch /var/www/storage/logs/laravel.log; then
    chmod 664 /var/www/storage/logs/laravel.log
    echo "Laravel log file is ready."
else
    echo "Failed to create or modify Laravel log file. Check permissions."
fi

# Clear Laravel cache
echo "Clearing Laravel cache..."
php /var/www/artisan config:clear
php /var/www/artisan cache:clear

which mysql
ls -l $(which mysql)

# Create database if it doesn't exist
echo "Creating database if it doesn't exist..."
mysql -h"$DB_HOST" -u"$DB_USERNAME" -p"$DB_PASSWORD" --ssl=0 -e "CREATE DATABASE IF NOT EXISTS $DB_DATABASE;"

echo "Testing database connectivity..."
php -r "
try {
    \$dbh = new PDO('mysql:host=${DB_HOST};port=${DB_PORT};dbname=${DB_DATABASE}', '${DB_USERNAME}', '${DB_PASSWORD}');
    echo \"Connected successfully to MySQL and selected database ${DB_DATABASE}.\n\";
    \$stmt = \$dbh->query('SHOW TABLES');
    echo \"Tables in ${DB_DATABASE}:\n\";
    while (\$row = \$stmt->fetch(PDO::FETCH_ASSOC)) {
        \$table = array_values(\$row)[0];
        echo \"- {\$table}\n\";
    }
} catch (PDOException \$e) {
    echo \"Connection failed: \" . \$e->getMessage() . \"\n\";
    exit(1);
}
"

# Run migrations if needed
if [ -f /var/www/artisan ]; then
    echo "Waiting for database to be fully ready..."
    sleep 5
    echo "Running migrations..."
    php /var/www/artisan migrate --force
else
    echo "Artisan file not found. Skipping migrations."
fi

# Start PHP-FPM
exec php-fpm
