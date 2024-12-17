Prequisites: 
Docker installed. (https://docs.docker.com/engine/install/ubuntu/)
Docker compose installed.

You need to have this dockerfile and all its dependencies including nginx/default.conf file in the laravel project folder.

Note: I made changes to the config/database.php file

Line 1-32 
<?php

use Illuminate\Support\Str;

$redisUrlString = env('REDIS_URL', ''); // Default to an empty string if null
$redisUrl = parse_url($redisUrlString);

$database = env('APP_REGION') == 'IN' ? env('IN_DB_DATABASE') : env('US_DB_DATABASE');

if (!isset($redisUrl['host'])) {
    $redisUrl = [
        'host' => '',
        'pass' => '',
        'port' => ''
    ];
}

$mysql = [
    'driver' => 'mysql',
    'host' => env('DB_HOST', '127.0.0.1'),
    'port' => env('DB_PORT', '3306'),
    'database' => env('DB_DATABASE', 'forge'),
    'username' => env('DB_USERNAME', 'forge'),
    'password' => env('DB_PASSWORD', ''),
    'unix_socket' => env('DB_SOCKET', ''),
    'charset' => 'utf8mb4',
    'collation' => 'utf8mb4_unicode_ci',
    'prefix' => '',
    'strict' => false,
    'prefix_indexes' => true,
    'engine' => null,
];

Made changes to config/logging.php file in line 46-57

'single' => [
            'driver' => 'single',
            'path' => storage_path('var/www/storage/logs/laravel.log'),
            'level' => env('LOG_LEVEL', 'debug'),
        ],

        'daily' => [
            'driver' => 'daily',
            'path' => storage_path('var/www/storage/logs/laravel.log'),
            'level' => env('LOG_LEVEL', 'debug'),
            'days' => 14,
        ],


To build the Docker image and run the docker containers run the below command:

docker compose up --build -d

the output will be as below:
[+] Building 2.4s (19/19) FINISHED                                                                                                         docker:desktop-linux
 => [app internal] load build definition from Dockerfile                                                                                                   0.0s
 => => transferring dockerfile: 1.99kB                                                                                                                     0.0s 
 => [app internal] load metadata for docker.io/library/php:8.2-fpm-alpine                                                                                  1.9s 
 => [app auth] library/php:pull token for registry-1.docker.io                                                                                             0.0s
 => [app internal] load .dockerignore                                                                                                                      0.0s
 => => transferring context: 2B                                                                                                                            0.0s 
 => [app  1/13] FROM docker.io/library/php:8.2-fpm-alpine@sha256:2e4805627ecfd6bc83037b0cfd9c89f834d5a57e68da1e3bc52727600fda9f07                          0.0s 
 => [app internal] load build context                                                                                                                      0.3s 
 => => transferring context: 336.75kB                                                                                                                      0.3s 
 => CACHED [app  2/13] WORKDIR /var/www                                                                                                                    0.0s
 => CACHED [app  3/13] RUN apk add --no-cache     libpng-dev     libjpeg-turbo-dev     freetype-dev     libzip-dev     zip     unzip     curl     msmtp    0.0s 
 => CACHED [app  4/13] RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer                            0.0s 
 => CACHED [app  5/13] RUN addgroup -g 1000 appgroup &&     adduser -D -u 1000 -G appgroup appuser                                                         0.0s 
 => CACHED [app  6/13] COPY --chown=appuser:appgroup . .                                                                                                   0.0s 
 => CACHED [app  7/13] RUN composer install --optimize-autoloader                                                                                          0.0s 
 => CACHED [app  8/13] RUN mkdir -p /var/www/storage/logs /var/www/bootstrap/cache &&     chown -R appuser:appgroup /var/www &&     chmod -R 775 /var/www  0.0s 
 => CACHED [app  9/13] RUN touch /var/www/storage/logs/laravel.log &&     chown appuser:appgroup /var/www/storage/logs/laravel.log &&     chmod 664 /var/  0.0s 
 => CACHED [app 10/13] COPY --chown=appuser:appgroup ./docker-entrypoint.sh /usr/local/bin/                                                                0.0s 
 => CACHED [app 11/13] COPY --chown=appuser:appgroup wait-for-it.sh /usr/local/bin/                                                                        0.0s 
 => CACHED [app 12/13] RUN chmod +x /usr/local/bin/docker-entrypoint.sh /usr/local/bin/wait-for-it.sh                                                      0.0s 
 => CACHED [app 13/13] RUN if [ -f /var/www/artisan ]; then chmod +x /var/www/artisan; fi                                                                  0.0s 
 => [app] exporting to image                                                                                                                               0.0s 
 => => exporting layers                                                                                                                                    0.0s 
 => => writing image sha256:3ad9f0a239049a9b5b406163dcf3fbf321e2d0bab7fcbbc2e353932cd7a76dc1                                                               0.0s 
 => => naming to docker.io/library/gigcampus-app                                                                                                           0.0s 
[+] Running 4/4
 ✔ Network gigcampus_laravel-network  Created                                                                                                              0.1s 
 ✔ Container gigcampus-db-1           Started                                                                                                              2.5s 
 ✔ Container gigcampus-app-1          Started                                                                                                              2.8s 
 ✔ Container gigcampus-nginx-1        Started                                                                                                              1.2s 

To check if containers are running
docker ps
Output should be like this 
                 
CONTAINER ID   IMAGE           COMMAND                  CREATED          STATUS         PORTS                  NAMES
03ec1a1eabf0   nginx:alpine    "/docker-entrypoint.…"   7 seconds ago    Up 5 seconds   0.0.0.0:8000->80/tcp   gigcampus-nginx-1
077a7ff54fad   gigcampus-app   "wait-for-it.sh db:3…"   9 seconds ago    Up 6 seconds   9000/tcp               gigcampus-app-1
3185cee9ccae   mysql:5.7       "docker-entrypoint.s…"   10 seconds ago   Up 6 seconds   3306/tcp, 33060/tcp    gigcampus-db-1

If container failed it will be in exit state, to check use below command
docker ps -a

To check logs of docker containers
docker logs (container id)
For e.g to check logs for app container do 
docker logs 077a7ff54fad

To check if the application is working you can run localhost:8000 to check if the application is working
