#!/usr/bin/env bash

[[ -z "$DB_NAME" ]] && echo "DB_NAME required" && exit 1;
[[ -z "$BUCKET" ]] && echo "BUCKET required" && exit 1;
[[ -z "$MONGODB_USER" ]] && echo "MONGODB_USER required" && exit 1;
[[ -z "$MONGODB_PASS" ]] && echo "MONGODB_PASS required" && exit 1;

DATE=$(date +%Y%m%d_%H%M)

if [[ "$MONGODB_HOST" == "" ]]; then
    MONGODB_HOST=localhost
fi

# Execute a database lookup
HAS_COLLECTIONS=$(mongo -u $MONGODB_USER -p $MONGODB_PASS --host $MONGODB_HOST $DB_NAME <<< "db.getCollectionNames().length > 0" |& grep "^true$")
if [[ "$HAS_COLLECTIONS" != "true" ]]
then
    echo "Database has no collections or we cannot connect"
    exit 1
fi

OUTPUT_FILE="/tmp/mongodb-$DB_NAME-dump_$DATE.tar.bz2"
DUMP_DIR=$(mktemp -d)

mongodump -u $MONGODB_USER -p $MONGODB_PASS --host $MONGODB_HOST --db $DB_NAME -o $DUMP_DIR
tar cjf $OUTPUT_FILE $DUMP_DIR

gsutil -m -h "Cache-Control:no-cache" cp -r "$OUTPUT_FILE" "gs://$BUCKET/"
rm -r $OUTPUT_FILE $DUMP_DIR
