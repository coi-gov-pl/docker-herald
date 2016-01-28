# Docker Herald

## Overview 

A docker image to run Herald tool on any Linux OS. Every env variable is prefixed with HERALD_


| ENV                              | DESCRIPTION                                 |          Default value|
| ---------------------------------| --------------------------------------------|----------|
| HERALD\_POSTGRES_HOST                   | IP host for PostgresSQL  |postgres|
| HERALD\_POSTGRES_PORT            | PostgresSQL port  |5432|
| HERALD\_POSTGRES_USER            | User that will be used to connect to database |pherald|
| HERALD\_POSTGRES\_DB_NAME        | Database name|pherald|
| HERALD\_POSTGRES_PASSWORD        | Password to database |VGh1IEphbiAyMSAxNDo1NzowOSBDRVQgMjAxNgo **Remeber to change this !**|
| HERALD\_POSTGRES\_CREATE_DATABASE| If set to `yes` scrip in the container will try to create database with provided env variables|yes|


## Run with PostgreSQL docker container

```
docker run -d -p 5432:5432 --name=postgres
docker run -d --link postgres -p 11303:11303 --name=herald coigovpl/herald
```

## Run with remote PostgreSQL
 
 ```
 docker run -d -e HERALD_POSTGRES_HOST=172.0.0.1 --name=herald coigovpl/herald 
 ```
 

## Run rake tests

```
rake
```

This command will run postgres container and link herald container to it. Later on it will make GET requests with curl to check if service is up and running