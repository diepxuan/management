#!/bin/bash

cd ~/public_html/code/docker

docker.exe ps -a -q | xargs docker.exe stop
docker.exe ps -a -q | xargs docker.exe rm

docker.exe rmi docker_apache70

# docker-compose.exe build
# docker-compose.exe up -d

# docker-compose.exe up
