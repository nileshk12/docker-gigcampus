#!/bin/sh
set -e

echo "Starting entrypoint script..."

# Display current user and group information
echo "Current user:"
id

# Check permissions and directory existence
echo "Checking permissions and directory structure..."
ls -la /var/www/storage
ls -la /var/www/storage/logs
ls -la /var/www/bootstrap/cache

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

# Run migrations if needed
if [ -f /var/www/artisan ]; then
    echo "Running migrations..."
    php /var/www/artisan migrate --force
else
    echo "Artisan file not found. Skipping migrations."
fi

echo "Entrypoint script completed. Starting PHP-FPM..."

# Start PHP-FPM
exec php-fpm