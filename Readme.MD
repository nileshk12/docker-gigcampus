Prequisites: 
Docker installed. (https://docs.docker.com/engine/install/ubuntu/)
Docker compose installed.

You need to have this dockerfile and all its dependencies in the laravel project folder


To build the image

docker compose build

To run the container after image build

docker compose up -d

To check if containers are running

docker ps

To check if container is in exit state

docker ps -a

To check logs of docker container

docker logs (container id)