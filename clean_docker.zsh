#!/bin/zsh

# Stop all running containers
docker stop $(docker ps -aq)

# Remove all containers
docker rm $(docker ps -aq)

# Remove all images without tags
docker images -q --filter dangling=true | xargs docker rmi

# Prune unused data
docker system prune -a -f

# Remove temporary files
rm -rf /var/lib/docker/tmp/*

# Prune volumes
docker volume prune -f

# Prune networks 
docker network prune -f
