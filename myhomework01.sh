#!/bin/sh
# Docker Home Work1
##################

# Network
# List the docker networks.
# docker network ls
# Create a new attachable network.
docker network create --attachable leinad
# Add a container to the network
# docker network connect leinad <CONTAINER>
# Inspect a Network
# docker network inspect leinad
# disconnect
# docker network disconnect leinad sq


# Postgres:
docker run --name pgdb -e POSTGRES_PASSWORD=password -d postgres
docker exec -ti pgdb psql -U postgres
# Create DB:
# CREATE DATABASE sonarqube WITH ENCODING 'UTF8';

# List DBs: \l
# to quit: \q

# Create DB: CREATE DATABASE sonarqube WITH ENCODING 'UTF8';

# Sonarqube

# Storage:
docker volume create --name sonarqube_data
docker volume create --name sonarqube_logs
docker volume create --name sonarqube_extensions

## Local
mkdir /home/ubuntu/storage/hw1/sq/sonarqube_data
mkdir /home/ubuntu/storage/hw1/sq/sonarqube_logs
mkdir /home/ubuntu/storage/hw1/sq/sonarqube_extensions

docker run -d --name sq \
    -p 9000:9000 \
    -e SONAR_JDBC_URL=jdbc:postgresql://pgdb/sonarqube \
    -e SONAR_JDBC_USERNAME=postgres \
    -e SONAR_JDBC_PASSWORD=password \
    -v sonarqube_data:/home/ubuntu/storage/hw1/sq/sonarqube_data \
    -v sonarqube_extensions:/home/ubuntu/storage/hw1/sq/sonarqube_extensions \
    -v sonarqube_logs:/home/ubuntu/storage/hw1/sq/sonarqube_logs \
    sonarqube:community

docker network connect leinad sq

# Jenkins
docker run --name jk -d -p 8080:8080 -p 50000:50000 jenkins/jenkins:lts-jdk11
docker network connect leinad jk

# Sonatype Nexus 3
mkdir /home/ubuntu/storage/hw1/nexus/nexus-data
sudo chown -R 200 /home/ubuntu/storage/hw1/nexus/nexus-data
docker run -d -p 8081:8081 -p 8082:8082 -p 8083:8083 --name nexus -v /home/ubuntu/storage/hw1/nexus/nexus-data:/nexus-data sonatype/nexus3

# Portainer
mkdir /home/ubuntu/storage/hw1/portainer/portainer_data

docker run -d -p 8002:8000 -p 9002:9000 --name=portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/home/ubuntu/storage/hw1/portainer/portainer_data portainer/portainer-ce

docker run -d -p 9001:9001 --name portainer_agent --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v /var/lib/docker/volumes:/var/lib/docker/volumes portainer/agent
