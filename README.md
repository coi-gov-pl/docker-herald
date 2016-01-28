# Docker Herald

## Overview 

A docker image to run Herald tool on any Linux OS. Every env variable isprefixed with HERALD_

## Run with PostgreSQL docker container

```
docker run -d -p 5433:5432 --name=postgres
docker run -d --link postgres -p 11303:11303 --name=herald coigovpl/heraldpostgres
```

## Run with remote PostgreSQL
 
 ```
 docker run -d -e POSTGRES_HOST=172.0.0.1 --name=herald coigovpl/heraldpostgres
 ```
 

## Run rake tests

```
rake
```

This command will run postgres container and link herald container to it. Later on it will make GET requests with curl to check if service is up and running