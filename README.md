# Docker container for Herald application

[![Build Status](https://travis-ci.org/coi-gov-pl/docker-herald.svg?branch=develop)](https://travis-ci.org/coi-gov-pl/docker-herald)

This is a Docker container that holds a Herald app inside. Herald is a puppet report processor that provides a gateway for consuming puppet reports, a REST API and a simple Web app to display them.

![A reports list](https://raw.githubusercontent.com/wavesoftware/gem-puppet-herald/gh-pages/images/reports.png)

More info about the application and how to use it with Puppet are available on repo page: https://github.com/wavesoftware/gem-puppet-herald

## Overview

A docker image to run Herald app on any Docker host: Linux, Mac or Windows. It utilize PostgreSQL as a database containing Puppet reports. While application stats it will try to migrate database to desired state.

## Configuration

Configuration can be provided by setting environment variables while running the container. Every env variable is prefixed with `HERALD_`

| ENV                              | DESCRIPTION                                 |          Default value|
| ---------------------------------| --------------------------------------------|----------|
| HERALD\_POSTGRES_HOST                   | IP host for PostgresSQL. If using container link, set it to postgres named container  |`postgres`|
| HERALD\_POSTGRES_PORT            | PostgresSQL port  |`5432`|
| HERALD\_POSTGRES_USER            | User that will be used to connect to database |`pherald`|
| HERALD\_POSTGRES\_DB_NAME        | Database name|`pherald`|
| HERALD\_POSTGRES_PASSWORD        | Password to database. **Remeber to set this variable for security!!!** |`VGh1IEphbiAyMSAxNDo1NzowOSBDRVQgMjAxNgo`|
| HERALD\_POSTGRES\_CREATE_DATABASE| If set to `yes` script in the container will try to create database and user with provided env variables|`yes`|

## Run with PostgreSQL docker container

If you like to run Herald with private docker container execute commands below:

```
docker run -d --name=postgres postgres
docker run -d --link postgres -p 11303:11303 --name=herald coigovpl/herald
```

## Run with remote PostgreSQL

If you like to run Herald with external postgres set appropriate configuration options with environment variables `HERALD_*` similar to:

```
docker run -d \
  -e HERALD_POSTGRES_HOST=herald-db.localdomain \
  -p 11303:11303 \
  --name=herald coigovpl/herald
```

## Sample system startup scripts that uses this container

file (executable) in `/etc/docker-apps/herald/container`:

```bash
#!/bin/bash -e

action=$1

export THISDIR=$(dirname $(readlink -f $0))
export CONTAINER=herald
HERALD_POSTGRES_PASSWORD=$(cat /etc/herald/passfile)

case $action in
  run)
    exec docker run --rm \
      --name $CONTAINER \
      -p 11303:11303 \
      -e HERALD_POSTGRES_HOST=herald-db.localdomain \
      -e HERALD_POSTGRES_PASSWORD=$HERALD_POSTGRES_PASSWORD \
      coigovpl/herald
    ;;
  kill)
    docker kill --signal 'SIGINT' $CONTAINER || true
    for i in $(seq 1 30); do
      running=$(docker inspect --format="{{ .State.Running }}" $CONTAINER || echo false)
      if [ "$running" == 'true' ]; then
        sleep 1
      else
        docker rm -f $CONTAINER || true
	      break
      fi
    done
  ;;
  *)
    echo './container <run|kill>' 1>&2
    exit 2
  ;;
esac
```

### systemd init file

file in: `/etc/systemd/system/herald.service`

```systemd
[Unit]
Description=Herald service
Requires=docker.service
After=docker.service

[Service]
Type=oneshot
RemainAfterExit=yes
WorkingDirectory=/etc/docker-apps/herald
ExecStart=/etc/docker-apps/herald/container run
ExecStop=/etc/docker-apps/herald/container kill

[Install]
WantedBy=local.target
```

## Running tests

```
rake test
```

This command will run postgres container and link herald container to it. Later on it will make GET requests with curl to check if service is up and running, and if everything is okey it will remove created containers to finish the test


## Contributing

Contributions are welcome!

To contribute, follow the standard [git flow](http://danielkummer.github.io/git-flow-cheatsheet/) of:

1. Fork it
1. Create your feature or bugfix branch (`git checkout -b feature/my-new-feature` or `git checkout -b bugfix/my-bugfix`)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to your fork (`git push origin feature/my-new-feature`)
1. Create new Pull Request

Even if you can't contribute code, if you have an idea for an improvement please open an [issue](https://github.com/coi-gov-pl/docker-herald/issues).
