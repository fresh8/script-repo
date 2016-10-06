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
PSQL_HOST=$3
PSQL_USER=$4

if [ "$PSQL_HOST" == "" ]; then
    PSQL_HOST=localhost
fi

if [ "$PSQL_USER" == "" ]; then
    PSQL_USER=postgres
fi

# Execute a database lookup
(psql -U "$PSQL_USER" -h "$PSQL_HOST" -lqt | cut -d \| -f 1 | grep -qw "$DB_NAME")
EXISTS=$?
if [[ "$EXISTS" != 0 ]]
then
    echo "Database does not exist"
    exit 1
fi

OUTPUT_FILE="/tmp/$DB_NAME-dump_$DATE.sql.bz2"

pg_dump -U postgres -h "$PSQL_HOST" "$DB_NAME" > "/tmp/$DB_NAME-dump_$DATE.sql"
LAST_MD5_FILE="/tmp/$DB_NAME-dump-md5"
if [ -f "$LAST_MD5_FILE" ]; then
  CURRENT_MD5=$(md5sum "/tmp/$DB_NAME-dump_$DATE.sql" | awk '{ print $1 }')
  LAST_MD5=$(cat "$LAST_MD5_FILE")

  if [ "$CURRENT_MD5" == "$LAST_MD5" ]
  then
    echo "No need to upload; no database content change"
    exit 0
  fi
fi

cat "/tmp/$DB_NAME-dump_$DATE.sql" | bzip2 > "$OUTPUT_FILE"
echo "$CURRENT_MD5" > "$LAST_MD5_FILE"

gsutil -m -h "Cache-Control:no-cache" cp -r "$OUTPUT_FILE" "gs://$BUCKET/"
