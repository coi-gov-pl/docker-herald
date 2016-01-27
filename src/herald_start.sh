#!/bin/bash -e

POSTGRES_HOST=${POSTGRES_HOST:-postgres}
POSTGRES_PORT=${POSTGRES_PORT:-5432}
POSTGRES_USER=${POSTGRES_USER:-pherald}
POSTGRES_DB_NAME=${POSTGRES_DB_NAME:-pherald}
# you should set password in the environment variable, do not use this example paswword
POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-VGh1IEphbiAyMSAxNDo1NzowOSBDRVQgMjAxNgo}
POSTGRES_DEPLOY_DATABASE=${POSTGRES_DEPLOY_DATABASE:-yes}
HERALD_PORT=11303

echo "$POSTGRES_PASSWORD" > /etc/pherald/passfile

if [[ $POSTGRES_DEPLOY_DATABASE=="yes" ]]; then
  psql -h $POSTGRES_PORT -d $POSTGRES_DB_NAME -U $POSTGRES_USER <<EOF
  DO
  $body$
  BEGIN
     IF NOT EXISTS (
        SELECT *
        FROM   pg_catalog.pg_user
        WHERE  usename = '${POSTGRES_USER}') THEN

        CREATE ROLE ${POSTGRES_USER} LOGIN PASSWORD "${POSTGRES_PASSWORD}"
          NOSUPERUSER INHERIT NOCREATEDB
          NOCREATEROLE NOREPLICATION ;
     END IF;
  END
  $body$;
EOF

  if [[ `psql postgres -tAc "SELECT 1 FROM pg_database WHERE datname='$POSTGRES_DB_NAME'"` == "1" ]]
  then
    echo "Database ${POSTGRES_DB_NAME} is already running"
  else
    psql -h $POSTGRES_PORT -d $POSTGRES_DB_NAME -U $POSTGRES_USER <<EOF
    CREATE DATABASE "${POSTGRES_DB_NAME}" WITH OWNER = ${POSTGRES_USER}
      ENCODING = 'UTF8'
      TABLESPACE = pg_default;
EOF
  fi
fi

exec puppet-herald \
  --dbconn postgresql://${POSTGRES_USER}@${POSTGRES_HOST}:${POSTGRES_PORT}/${POSTGRES_DB_NAME} \
  --passfile /etc/pherald/passfile \
  --bind 127.0.0.1 "$@"
