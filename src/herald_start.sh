#!/bin/bash -e

HERALD_POSTGRES_HOST=${POSTGRES_HOST:-postgres}
HERALD_PORT_POSTGRES=${POSTGRES_POR:-5432}
HERALD_POSTGRES_USER=${POSTGRES_USER:-pherald}
HERALD_POSTGRES_DB_NAME=${POSTGRES_DB_NAME:-pherald}
# you should set password in the environment variable, do not use this example paswword
HERALD_POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-VGh1IEphbiAyMSAxNDo1NzowOSBDRVQgMjAxNgo}
HERALD_POSTGRES_CREATE_DATABASE=${POSTGRES_DEPLOY_DATABASE:-yes}
HERALD_PORT=11303

echo "$HERALD_POSTGRES_PASSWORD" > /etc/pherald/passfile

if [[ $HERALD_POSTGRES_CREATE_DATABASE=="yes" ]]; then

  cat > /tmp/create-user.sql <<EOF
  DO
  \$body$
  BEGIN
     IF NOT EXISTS (
        SELECT *
        FROM   pg_catalog.pg_user
        WHERE  usename = '${HERALD_POSTGRES_USER}') THEN

        CREATE ROLE "${HERALD_POSTGRES_USER}" LOGIN PASSWORD '${HERALD_POSTGRES_PASSWORD}'
          NOSUPERUSER INHERIT CREATEDB
          NOCREATEROLE NOREPLICATION ;
     END IF;
  END
  \$body$;
EOF
  psql -h $HERALD_POSTGRES_HOST -p $HERALD_PORT_POSTGRES -U postgres -d postgres < /tmp/create-user.sql

  if [[ `psql -h $HERALD_POSTGRES_HOST -p $HERALD_PORT_POSTGRES -d postgres -U $HERALD_POSTGRES_USER -tAc "SELECT 1 FROM pg_database WHERE datname='$HERALD_POSTGRES_DB_NAME'"` == "1" ]]
  then
    echo "Database ${HERALD_POSTGRES_DB_NAME} is already running"
  else
    psql -h $HERALD_POSTGRES_HOST -p $HERALD_PORT_POSTGRES -d postgres -U postgres <<EOF
    CREATE DATABASE "${HERALD_POSTGRES_DB_NAME}" WITH OWNER = "${HERALD_POSTGRES_USER}"
      ENCODING = 'UTF8'
      TABLESPACE = pg_default;
EOF
  fi
fi

exec puppet-herald \
  --dbconn postgresql://${POSTGRES_USER}@${POSTGRES_HOST}:${PORT_POSTGRES}/${POSTGRES_DB_NAME} \
  --passfile /etc/pherald/passfile \
  --bind 0.0.0.0 "$@"
