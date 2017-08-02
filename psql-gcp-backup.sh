#!/usr/bin/env bash

if [ "$1" == "" ]; then
    echo "Database name required"
    exit 1
fi

if [ "$2" == "" ]; then
    echo "Bucket name required"
    exit 1
fi

DATE=$(date +%Y%m%d_%H%M)
DB_NAME=$1
BUCKET=$2
PSQL_USER=$3

if [ "$PSQL_USER" == "" ]; then
    PSQL_USER=postgres
fi

$(psql -U "$PSQL_USER" -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME")
EXISTS=$?
if [[ "$EXISTS" != 0 ]]
then
    echo "Database does not exist"
    exit 1
fi

pg_dump -U postgres "$DB_NAME" > "/tmp/$DB_NAME-dump_$DATE.sql"
gsutil -m -h "Cache-Control:no-cache" cp -r "/tmp/$DB_NAME-dump_$DATE.sql" "gs://$BUCKET/"

rm /tmp/$DB_NAME-dump_$DATE.sql
