FROM php:8.2-fpm-alpine

# Set environment variables for UID and GID
ENV PUID=1000
ENV PGID=1000

WORKDIR /var/www

# Install dependencies and PHP extensions
RUN apk add --no-cache \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libzip-dev \
    zip \
    unzip \
    curl \
    msmtp \
    shadow \
    bash \
    nano \
    && docker-php-ext-configure gd --with-freetype --with-jpeg=/usr/include/ \
    && docker-php-ext-install gd pdo pdo_mysql zip pcntl

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Create a non-root user with a non-interactive shell
RUN addgroup -g ${PGID} appgroup && \
    adduser -D -u ${PUID} -G appgroup appuser

# Copy project files
COPY --chown=appuser:appgroup . .

# Run composer install to install dependencies
RUN composer install --no-dev --optimize-autoloader

# Ensure storage and bootstrap cache directories exist with proper permissions
RUN mkdir -p /var/www/storage/logs /var/www/bootstrap/cache && \
    chown -R appuser:appgroup /var/www && \
    chmod -R 775 /var/www

# Ensure Laravel log file exists and has correct permissions
RUN touch /var/www/storage/logs/laravel.log && \
    chown appuser:appgroup /var/www/storage/logs/laravel.log && \
    chmod 664 /var/www/storage/logs/laravel.log

# Add startup script and wait-for-it script
COPY --chown=appuser:appgroup ./docker-entrypoint.sh /usr/local/bin/
COPY --chown=appuser:appgroup wait-for-it.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh /usr/local/bin/wait-for-it.sh

# Ensure artisan is executable
RUN if [ -f /var/www/artisan ]; then chmod +x /var/www/artisan; fi

EXPOSE 9000

# Switch to non-root user
USER appuser

# Start the container using the entrypoint script
ENTRYPOINT ["wait-for-it.sh", "db:3306", "--", "/usr/local/bin/docker-entrypoint.sh"]
